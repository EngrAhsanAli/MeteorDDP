//
//  MeteorClient.swift
//  MeteorDDP
//
//  Created by engrahsanali on 2020/04/17.
//  Copyright (c) 2020 engrahsanali. All rights reserved.
//
/*
 
 Copyright (c) 2020 Muhammad Ahsan Ali, AA-Creations
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
*/

//
// This software uses CryptoSwift: https://github.com/krzyzanowskim/CryptoSwift/
//

import Foundation
import CryptoSwift

// MARK:- 🚀 Meteor Client - Responsible to manage DDP interaction with provided websocket events
public final class MeteorClient {
    
    var version: String                                     // ddp version
    
    var support: [String]                                   // ddp support
    
    var socket: MeteorWebSockets                            // web sockets
    
    var subHandler = [String: SubHolder]()                  // subscription handler
    
    var methodHandler = [String: MethodHolder]()            // methods handler
    
    var connectedCallback: ((String) -> ())?                // meteor connected callback
    
    var loggedInUser: UserHolder?                           // persisted logged in user
    
    var backOff = ExponentialBackoff()                      // exponantional back off for ddp failure
    
    var server: (ping: Date?, pong: Date?) = (nil, nil)     // ddp ping pong
        
    var collections = [String: MeteorCollections]()         // collections handler with name
    
    weak public var delegate: MeteorDelegate?               // meteor ddp and websocket events delegate
            
    // Background data queue
    let backgroundQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "\(METEOR_DDP) Background Data Queue"
        queue.qualityOfService = .background
        return queue
    }()
    
    // Callbacks execute in the order they're received
    let methodResultQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "\(METEOR_DDP) Callback Queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    // Document messages are processed in the order that they are received, separately from callbacks
    let documentQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "\(METEOR_DDP) Background Queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
    
    // Queue for server ping pong handling
    let heartbeat: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "\(METEOR_DDP) Heartbeat Queue"
        queue.qualityOfService = .utility
        return queue
    }()
    
    // Background queue for current user
    let userBackground: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "\(METEOR_DDP) High Priority Background Queue"
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    // Main queue for current user
    let userMainQueue: OperationQueue = {
        let queue = OperationQueue.main
        queue.name = "\(METEOR_DDP) High Priorty Main Queue"
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    // Warning to avoid synchronous operations on main UI thread
    let syncWarning = { (name: String) -> () in
        if Thread.isMainThread {
            logger.logError(.mainThread, "\(name) is running synchronously on the main thread. It should run on a background thread")
        }
    }
    
    /// DDP client to init with websocket interface and configurations
    /// - Parameters:
    ///   - url: websocket url
    ///   - webSocket: websocket method for preference
    ///   - requestTimeout: network request max timeout
    ///   - version: ddp version
    ///   - support: ddp support
    public init(url: String,
                webSocket: WebSocketMethod = .starscream,
                requestTimeout: Double = 15,
                version: String = "1",
                support: [String] = ["1"]) {
        
        self.version = version
        self.support = support
        self.socket = MeteorWebSockets(url, webSocket, requestTimeout)

    }
    
    /// DDP client to init with websocket interface and configurations
    /// - Parameters:
    ///   - url: websocket url
    ///   - webSocket: websocket interface
    ///   - requestTimeout: network request max timeout
    ///   - version: ddp version
    ///   - support: ddp support
    public init(url: String,
                webSocket: MeteorWebSockets,
                requestTimeout: Double = 15,
                version: String = "1",
                support: [String] = ["1"]) {
        
        self.version = version
        self.support = support
        self.socket = webSocket

    }
    
    /// Connects the ddp server and bind websocket events with the provided websocket interfacxe
    /// - Parameter callback: ddp session
    public func connect(callback: ((String) -> ())?) {
        connectedCallback = callback
        backOff = ExponentialBackoff()
        bindEvent()
        socket.configureWebSocket()
        
    }
    
    /// Disconnects and remove events for provided websocket interface
    public func disconnect() {
        socket.onEvent = nil
        delegate = nil
        notificationCenter.removeObserver(self)
        socket.disconnect()
    }
    
}

// MARK:- 🚀 Meteor Client - 
internal extension MeteorClient {
    
    /// Send ddp message
    /// - Parameter msgs: list of ddp outgoing messages 
    func sendMessage(msgs: [MessageOut])  {
        syncWarning("Socket Message send")
        let msg = makeMessage(msgs).toJson!
        logger.log(.socket, msg)
        socket.send(msg)
    }
    
    /// Bind websocket events
    fileprivate func bindEvent() {
        
        let events: ((WebSocketEvent) -> ()) = { event in
            switch event {
                
            case .connected:
                self.eventOnOpen()
                
            case .disconnected:
                self.triggerReconnect()
                
            case let .text(text):
                self.handleResponse(text)
                
            case let .error(error):
                logger.logError(.socket, "\(String(describing: error?.localizedDescription))")
            }
            self.delegate?.didReceive(name: .websocket, event: event)
        }
        socket.onEvent = events
    }
    
    /// Handle response in queue
    /// - Parameter text: Incomming message
    func handleResponse(_ text: String) {
        backgroundQueue.addOperation() {
            self.messageInHandle(text)
        }
    }
    
    /// Auto trigger reconnection
    fileprivate func triggerReconnect() {
        backOff.createBackoff {
            self.socket.configureWebSocket()
            self.ping()
        }
    }
    
    /// DDP connection open event
    fileprivate func eventOnOpen() {
        
        heartbeat.addOperation() {
            self.backOff.reset()
            self.sendMessage(msgs: [.msg(.connect), .version(self.version), .support(self.support)])
        }
        
    }
    
    /// DDP loginServiceConfiguration
    func loginServiceSubscription() {
        let loginServiceConfig = "meteor.loginServiceConfiguration"
        self.subscribe(loginServiceConfig, params: nil)

        self.subHandler.filter {
            $1.name != loginServiceConfig
        }.forEach {
            self.sub($1.id, name: $1.name, params: nil, collectionName: nil, callback: nil)
        }
        
        if !self.loginWithToken({ result, error in
            guard let error = error else {
                logger.log(.login, "Auto resumed previous login session")
                return
            }
            self.logout()
            error.log(.login)
        }) {
            self.logout()
        }
    }
    
}



