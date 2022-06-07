//
//  MeteorWebSockets.swift
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

import Starscream
import SystemConfiguration

// MARK:- WebSocketMethod
public enum WebSocketMethod {
    case starscream, webSocketTask, custom
}

// MARK:- 🚀 MeteorWebSockets
public class MeteorWebSockets {
    
    internal var url: URL
    internal var socket: Any?
    internal var preferredMethod: WebSocketMethod
    internal var onEvent: ((WebSocketEvent) -> ())?
    internal var timeout: TimeInterval
    internal var isConnected: Bool = false
    
    /// Init
    /// - Parameters:
    ///   - url: websocket url endpoint
    ///   - method: Starscream or URLSessionWebSocketTask
    ///   - timeout: request timeout
    public init(_ url: String, _ method: WebSocketMethod = .webSocketTask, _ timeout: Double) {
        self.url = url.websocketUrl
        self.preferredMethod = method
        self.timeout = TimeInterval(timeout)
    }
    
}


// MARK:- 🚀 MeteorDDP - MeteorWebSockets internal extension
internal extension MeteorWebSockets {
    
    /// Configuration
    func configureWebSocket() {
        socket = nil
        
        if preferredMethod == .webSocketTask {
            if #available(iOS 13.0, *) { socket = configureWebSocketTask() }
            else { preferredMethod = .custom }
        }
        
        if socket == nil {
            switch preferredMethod {
            case .starscream:       socket = configureStarscream()
            default:                socket = configureWebSocketCustom()
            }
        }

    }
    
    /// Disconnect on demand
    func disconnect() {
        if let socket = socket as? WebSocket {
            socket.forceDisconnect()
        }
        else if let socket = socket as? WebSocketCustom {
            socket.close()
        }
        else if #available(iOS 13.0, *) {
            if let socket = socket as? WebSocketTask {
                socket.disconnect()
            }
        }
    }
    
    /// Send message to websocket
    /// - Parameter text: String
    func send(_ text: String) {
        if let socket = socket as? WebSocket {
            socket.write(string: text, completion: nil)
        }
        else if let socket = socket as? WebSocketCustom {
            socket.send(text)
        }
        else if #available(iOS 13.0, *) {
            if let socket = socket as? WebSocketTask {
                socket.send(text: text)
            }
        }
    }
    
    /// Check network connectivity and through Error
    var noInternetError: Error? {
        guard !isConnectedToNetwork else {
            return nil
        }
        
        return NSError(domain: "", code: -1009, userInfo: nil)
        
    }
    
    /// Check network connectivity
    var isConnectedToNetwork: Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
        
    }
}

// MARK: Configure different Websocket methods
private extension MeteorWebSockets {
    
    /// Configure Starscream Websocket
    func configureStarscream() -> WebSocket {
        var request = URLRequest(url: url)
        request.timeoutInterval = timeout
        let socket = WebSocket(request: request)
        socket.onEvent = { event in
            switch event {
            case .connected(let session):
                self.isConnected = true
                self.onEvent?(.connected)
                logger.log(.socket, "Connection started with session \(session)", .info)
            case .disconnected(let reason, let code):
                self.isConnected = false
                self.onEvent?(.disconnected)
                logger.log(.socket, "Connection closed with code \(code). \(reason)", .info)
            case .text(let text):
                self.onEvent?(.text(text))
            case .error(let error):
                self.isConnected = false
                self.onEvent?(.error(error))
            case .cancelled:
                self.isConnected = false
                self.onEvent?(.disconnected)
            default:
                self.isConnected = false
                self.onEvent?(.error(self.noInternetError))
                
            }
        }
        return socket
    }
    
    /// Configure URLSessionWebSocketTask
    @available(iOS 13.0, *)
    func configureWebSocketTask() -> WebSocketTask {
        let socket = WebSocketTask(url: url, timeout: timeout)
        socket.onEvent = onEvent
        socket.isConnected = { self.isConnected = $0 }
        socket.connect()
        return socket
    }
    
    /// Configure WebSocketCustom
    func configureWebSocketCustom() -> WebSocketCustom {
        let socket = WebSocketCustom(url: url)
        socket.setTimeout(timeout)
        socket.services = [.VoIP, .Background]

        socket.event.open = {
            self.isConnected = true
            self.onEvent?(.connected)
            logger.log(.socket, "Connection started with session", .info)
        }
        socket.event.close = { code, reason, clean in
            self.isConnected = false
            self.onEvent?(.disconnected)
            logger.log(.socket, "Connection closed with code \(code). \(reason)", .info)
        }
        socket.event.error = { error in
            self.isConnected = false
            self.onEvent?(.error(error))
        }
        socket.event.message = { message in
            guard let text = message as? String else { return }
            self.onEvent?(.text(text))
        }
        socket.event.end = { code, reason, _, _ in
            self.isConnected = false
            self.onEvent?(.disconnected)
            logger.log(.socket, "Connection closed with code \(code). \(reason)", .info)
        }
        socket.open(nsurl: url)
        return socket
    }
    
}
