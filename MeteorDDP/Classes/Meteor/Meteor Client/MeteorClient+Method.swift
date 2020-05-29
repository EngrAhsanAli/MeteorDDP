//
//  MeteorClient+Method.swift
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

// MARK:- 🚀 MeteorClient+Method - interacting with basic Meteor server-side services
public extension MeteorClient {
    
    /// Executes a method on the server. If a callback is passed, the callback is asynchronously executed when the method has completed. The callback takes two arguments: result and error. It the method call is successful, result contains the return value of the method, if any. If the method fails, error contains information about the error.
    /// - Parameters:
    ///   - name: The name of the method
    ///   - params: An object containing method arguments, if any
    ///   - callback: The closure to be executed when the method has been executed
    @discardableResult
    func call(_ name: String, params: [Any]?, callback: MeteorMethodCallback? = nil) -> String {
        let id = String.randomString
        var messages: [MessageOut] = [.msg(.method), .method(name), .id(id)]
        
        if let callback = callback {
             self.methodHandler[id] = MethodHolder(name: name, completion: callback)
         }
        
        if let p = params {
            messages.append(.params(p))
        }
        
        userBackground.addOperation() {
            self.sendMessage(msgs: messages)
        }
        return id
    }

}
