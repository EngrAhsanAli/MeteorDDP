//
//  MeteorError.swift
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


// MARK:- MeteorError
// A struct encapsulating a DDP error message
// MARK:- 🚀 MeteorClient Error -
public struct MeteorError: Error {
    
    /// DDP error message
    fileprivate var keyValue: MeteorKeyValue?
    
    /// Error description
    public var error: String? {
        keyValue?["error"] as? String
    }
    
    /// Error reason
    public var reason: String? {
        keyValue?["reason"] as? String
    }
    
    /// Error validiity
    var isValid: Bool {
        if error != nil || reason != nil {
            return true
        }
        return false
    }
    
    /// Create Error object from DDP message
    /// - Parameter message: DDP message dictionary
    init(_ message: Any?) {
        self.keyValue = message as? MeteorKeyValue
    }

}

// MARK:- 🚀 MeteorClient Error -
extension MeteorError {
    
    
    /// Logs the error if valid
    /// - Parameter label: tag label
    func log(_ label: MeteorLogger.LogTags = .error) {
        logger.logError(label, keyValue ?? localizedDescription)
    }
}
