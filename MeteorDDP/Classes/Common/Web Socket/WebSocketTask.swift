//
//  WebSocketTask.swift
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


import Combine

// MARK:- 🚀 MeteorDDP - WebSocketTask internal class
@available(iOS 13.0, *)
internal class WebSocketTask: NSObject {

    var onEvent: ((WebSocketEvent) -> Void)?
    
    let delegateQueue = OperationQueue()
    
    var webSocketTask: URLSessionWebSocketTask!
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - timeout: <#timeout description#>
    init(url: URL, timeout: Double) {
        super.init()
        
        let configuration: URLSessionConfiguration = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = TimeInterval(timeout)
            return configuration
        }()
        
        let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
        webSocketTask = urlSession.webSocketTask(with: url)
    }
    
    /// <#Description#>
    func connect() {
        webSocketTask.resume()
        listen()
    }
    
    /// <#Description#>
    func disconnect() {
        webSocketTask.cancel(with: .goingAway, reason: nil)
    }
    
    /// <#Description#>
    func listen()  {
        webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                self.onEvent?(.error(error))
            case .success(let message):
                switch message {
                case .string(let text):
                    self.onEvent?(.text(text))
                default:
                    break
                }
                self.listen()
            }
        }

    }
    
    /// <#Description#>
    /// - Parameter text: <#text description#>
    func send(text: String) {
        webSocketTask.send(URLSessionWebSocketTask.Message.string(text)) { error in
            if let error = error {
                self.onEvent?(.error(error))
            }
        }
    }
    
    /// <#Description#>
    /// - Parameter data: <#data description#>
    func send(data: Data) {
        webSocketTask.send(URLSessionWebSocketTask.Message.data(data)) { error in
            if let error = error {
                self.onEvent?(.error(error))
            }
        }
    }
    
}

// MARK:- 🚀 MeteorDDP - URLSessionWebSocketDelegate
@available(iOS 13.0, *)
extension WebSocketTask: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        onEvent?(.connected)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        onEvent?(.disconnected)
    }
    
}
