//
//  MeteorClient+Message.swift
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

// MARK:- 🚀 MeteorClient+Message - interacting with basic Meteor server-side services
internal extension MeteorClient {
    
    func ping() {
        heartbeat.addOperation() {
            self.sendMessage(msgs: [.msg(.ping), .id(String.randomString)])
        }
      }
      
    // Respond to a server ping
    func pong(_ id: String?) {
        heartbeat.addOperation() {
            self.server.ping = Date()
            var msg: [MessageOut] = [.msg(.pong)]
            if let id = id {
                msg.append(.id(id))
            }
            self.sendMessage(msgs: msg)
        }
    }
    
    /// Parse DDP messages and dispatch to the appropriate function
    /// - Parameter text: Incomming message
    func messageInHandle(_ text: String) {
        guard text.count > 0 else {
            return
        }
        
        let message = MessageIn(message: text)
        
        if let type = message.type {
            
            switch type {
                
            case .server(let s):
                switch s {
                    
                case .connected:
                    self.sessionId = message.session
                    self.onSessionConnected?(sessionId!)
                    self.loginServiceSubscription()
                    self.broadcastEvent(MeteorEvents.connected.rawValue, event: .connected, value: sessionId!)
                    message.log(.info)
                    
                case .ping:
                    heartbeat.addOperation() {
                        self.pong(message.id)
                    }
                    message.log(.info)
                    
                case .pong:
                    heartbeat.addOperation() {
                        self.server.pong = Date()
                    }
                    message.log(.info)
                    
                case .ready:
                    guard let subs = message.subs else {
                        return
                    }
                    documentQueue.addOperation() {
                        self.ready(subs)
                    }
                    message.log(.info)
                    
                case .nosub:
                    guard let id = message.id else {
                        return
                    }
                    documentQueue.addOperation() {
                        self.nosub(id, error: message.error)
                    }
                    message.log(.info)
                }
                
            case .method(let s):
                handleMethod(message, type: s)
                message.log(.incomming)
                
            case .sub(let s):
                handleSub(message, type: s)
                message.log(.incomming)
                
            }
            
        }
    }
    
}

// MARK:- 🚀 Meteor Client -
fileprivate extension MeteorClient {
    
    /// Handle DDP Subscription
    /// - Parameters:
    ///   - message: Incomming Message
    ///   - type: Event type
    func handleSub(_ message: MessageIn, type: MessageIn.MessageInSub) {
        if let collection = message.collection,
            let id = message.id {
            
            var event: MeteorCollectionEvents
            var result: MeteorDocument
            
            switch type {
                
            case .added:
                event = .dataAdded
                result = MeteorDocument(name: collection, id: id, fields: message.fields, cleared: nil)
                
            case .changed:
                event = .dataChange
                result = MeteorDocument(name: collection, id: id, fields: message.fields, cleared: message.cleared)
                
            case .removed:
                event = .dataRemove
                result = MeteorDocument(name: collection, id: id, fields: nil, cleared: nil)
                
            }
            
            broadcastEvent(collection, event: event.meteorEvent, value: result)
            invokeCallback(byCollection: collection, event, result)
            
        }
    }
    
    /// Handle Method Response
    /// - Parameters:
    ///   - message: Response
    ///   - type: Method
    func handleMethod(_ message: MessageIn, type: MessageIn.MessageInMethod) {
        methodResultQueue.addOperation() {
            DispatchQueue.main.async {
                
                guard let id = message.id, let method = self.methodHandler?[id] else { return }
                
                switch type {
                    
                case .result:
                    method.completion(message.result, message.error)
                    
                    let result = MeteorMethod(name: method.name, result: message.result, error: message.error)
                    self.broadcastEvent(method.name, event: .method, value: result)
                    self.methodHandler?[id] = nil
                    
                case .error:
                    
                    let error = MeteorError(message.message)
                    let result = MeteorMethod(name: method.name, result: nil, error: error)
                    self.broadcastEvent(method.name, event: .method, value: result)
                }
            }
        }
        
    }
    
    
    /// Invoke the callback of method against that collection name
    /// - Parameters:
    ///   - collection: collection Name
    ///   - event: Meteor event
    ///   - result: Meteor document
    func invokeCallback(byCollection collection: String, _ event: MeteorCollectionEvents, _ result: MeteorDocument) {
        DispatchQueue.main.async {
            self.findSubscription(byCollection: collection)?.callback?(event, result)
        }
        
    }
}
