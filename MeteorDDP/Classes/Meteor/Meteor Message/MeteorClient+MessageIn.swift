//
//  MeteorClient+MessageIn.swift
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

// MARK:- MeteorClient+MessageIn
// A struct to parse, encapsulate and facilitate handling of DDP message strings
// todo change it meteorkeyvalue extension
// MARK:- 🚀 MeteorClient+MessageIn -
internal class MessageIn {
    
    var keyValue: MeteorKeyValue
    
    var response: String
    
    /// MessageIn object from DDP message
    /// - Parameter message: incomming message string
    init(message: String) {
        self.response = message
        keyValue = message.keyValue
    }
    
    /// Message type
    var type: MessageInTypes? {
        if let msg = message {
            if let server = MessageInServer(rawValue: msg) {
                return .server(server)
            }
            else if let method = MessageInMethod(rawValue: msg) {
                return .method(method)
            }
            else if let sub = MessageInSub(rawValue: msg) {
                return .sub(sub)
            }
        }
        
        return nil
        
    }
    
    
    /// Message
    var message: String? { keyValue["msg"] as? String }

    
    /// Sesssion
    var session: String? { keyValue["session"] as? String }
    
    
    /// ID
    var id: String? { keyValue["id"] as? String }
    
    
    /// Collection
    var collection: String? { keyValue["collection"] as? String }
    
    
    /// Fields for collection
    var fields: MeteorKeyValue { (keyValue["fields"] as? MeteorKeyValue) ?? [:] }
    
    
    /// Removed fields names
    var cleared: [String]? { keyValue["cleared"] as? [String] }
    
    
    /// Result
    var result: Any? { keyValue["result"] }
    
    
    /// Method names
    var methods: [String]? { keyValue["methods"] as? [String] }
    
    
    /// Subscription IDs
    var subs: [String]? { keyValue["subs"] as? [String] }
    
    
    /// MeteorError
    var error: MeteorError? {
        let err = keyValue["error"] as? MeteorKeyValue
        let error = MeteorError(err)
        if !error.isValid {
            return nil
        }
        return error
    }

}

// MARK:- 🚀 MeteorClient+MessageIn -
internal extension MessageIn {
    
    
    /// Logs the message in console
    func log(_ type: MeteorLogger.Level) {
        if message != nil {
            logger.log(.receiveMessage, response, type)
        }
        else {
            logger.logError(.receiveMessage, response)
        }
    }
}

// MARK:- 🚀 MeteorClient+MessageIn -
internal extension MessageIn {
    
    /// MessageInTypes
    enum MessageInTypes {
        case server(MessageInServer)
        case method(MessageInMethod)
        case sub(MessageInSub)
    }
    
    // MARK:- MeteorMessageType
    enum MessageInServer: String {
        case connected, ping, pong
        case ready, nosub
    }
    
    /// MessageInMethod
    enum MessageInMethod: String {
        case result, error
    }
    
    /// MessageInSub
    enum MessageInSub: String {
        case added, changed, removed
    }
}
