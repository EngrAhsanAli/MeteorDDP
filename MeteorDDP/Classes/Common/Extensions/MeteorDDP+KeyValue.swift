//
//  MeteorDDP+KeyValue.swift
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


// MARK:- 🚀 MeteorDDP - MeteorKeyValue internal extension
internal extension MeteorKeyValue {
    
    /// Convert EJSON date to timestamp
    var dateFromTimestamp: Date {
        let date = self["$date"] as? Double
        let timestamp = TimeInterval(date! / 1000)
        return Date(timeIntervalSince1970: timestamp)
    }
    
}

// MARK:- 🚀 MeteorDDP - MeteorKeyValue internal extension
public extension MeteorKeyValue {
    
    /// Converts KeyValue to object
    /// - Parameter type: Codable class type
    func object<T>(type: T.Type) -> T? where T: Decodable {
        return MeteorEncodable.decode(type, from: self)
    }
    
    /// Converts KeyValue to json string
    var toJson: String? {
        if let data = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions(rawValue: 0)) {
            return String(data: data, encoding: String.Encoding.utf8)
        }
        return nil
    }

}
