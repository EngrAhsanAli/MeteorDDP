//
//  MeteorLogger.swift
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


// MARK:- 🚀 MeteorLogger - Prints the information in defined manner
open class MeteorLogger {
    
    /// Flag to allow logging information  in the application
    public static var loggingEnabled = true
    
    /// Print header
    fileprivate func printTag() {
        print("\n ❕ ❕ ❕ 🚀 \(METEOR_DDP) ❕ ❕ ❕")
    }
    
    /// Print log information
    /// - Parameters:
    ///   - label: tag
    ///   - items: items to print
    internal func log(_ label: LogTags, _ items: Any) {
        guard MeteorLogger.loggingEnabled else {
            return
        }
        printTag()
        print("\(label.rawValue) 👉🏼 \(items)", terminator: "\n\n")

    }
    
    /// Print log information
    /// - Parameters:
    ///   - label: tag
    ///   - items: items to print
    internal func logError(_ label: LogTags, _ items: Any...) {
        printTag()
        print("\(label.rawValue) 👉🏼 \(items)", terminator: " ‼️ \n\n")
        
    }

}

// MARK:- 🚀 MeteorLogger - internal protection
internal extension MeteorLogger {
    
    /// Loggging tags
    enum LogTags : String {
        case login = "Login"
        case signup = "Sign up"
        case sub = "Meteor Subscribe"
        case unsub = "Meteor Unsubscribe"
        case doc = "Meteor Document"
        case receiveMessage = "Meteor Receive Message"
        case socket = "Web Socket"
        case mainThread = "Main Thread Warning"
        case error = "Meteor Error"
    }
}
