//
//  MeteorClient+MessageOut.swift
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

// MARK:- 🚀 MeteorClient MessageOut - provide easy handling to ddp outgoing messages
internal extension MeteorClient {
    
    /// Makes Key-Value from given outgoing server interaction messages list
    /// - Parameter messages: list of messages
    func makeMessage(_ messages: [MessageOut]) -> MeteorKeyValue {
        var message = MeteorKeyValue()
        
        messages.forEach {
            
            switch $0 {
                
            case .version(let p):   message["version"] = p
                
            case .support(let p):   message["support"] = p

            case .id(let p):        message["id"] = p
                
            case .name(let p):      message["name"] = p
                
            case .params(let p):    message["params"] = p
                
            case .method(let p):    message["method"] = p
            
            case .msg(let m):
                
                switch m {
                    
                case .connect:  message["msg"] = "connect"
                    
                case .ping:     message["msg"] = "ping"
                    
                case .pong:     message["msg"] = "pong"
                    
                case .unsub:    message["msg"] = "unsub"
                    
                case .sub:      message["msg"] = "sub"
                    
                case .method:   message["msg"] = "method"
                    
                }
                
            }
        }
        
        return message
    }
    
    /// Makes Key-Value from given outgoing User Messages list
    /// - Parameter messages: User Messages list
    func makeMessage(_ messages: [UserMessage]) -> MeteorKeyValue {
        var message = MeteorKeyValue()
        messages.forEach {
            switch $0 {
                
            case .email(let p):     message["email"] = p
                
            case .username(let p):  message["user"] = ["username": p]

            case .password(let p):  message["password"] = ["digest" : p.sha256(), "algorithm":"sha-256"]
                
            case .profile(let p):   message["profile"] = p
            
            }
        }
        
        return message
    }
    
}

// MARK:- 🚀 MeteorClient MessageOut - provides easy handling to ddp outgoing messages
internal extension MeteorClient {
    
    /// DDP outgoing erver interaction messages types
    enum MessageOut {
        case version(String), support([String])
        case id(String), name(String), method(String)
        case msg(MsgType)
        case params([Any])
        
        /// Server indicate message types for ddp events
        enum MsgType {
            case connect, sub, unsub, ping, pong, method
        }
        
    }
    
    /// DDP outgoing user messages types
    enum UserMessage {
        case email(String), username(String), password(String)
        case profile(MeteorKeyValue)
    }

}
