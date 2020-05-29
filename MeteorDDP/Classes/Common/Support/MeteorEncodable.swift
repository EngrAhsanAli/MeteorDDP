//
//  MeteorEncodable.swift
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

// MARK:- 🚀 MeteorEncodable - provide support to convert MeteorKeyValue to Encodable format
open class MeteorEncodable {
        
    /// Encodes given Encodable value into an array or dictionary
    /// - Parameter value: MeteorKeyValue type object
    open class func encode<T>(_ value: T) throws -> Any? where T: Encodable {
        let jsonEncoder = JSONEncoder()
        if let jsonData = try? jsonEncoder.encode(value) {
            return try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
        }
        return nil
    }
        
    /// Decodes given Decodable type from given array or dictionary
    /// - Parameters:
    ///   - type: type of Codable class
    ///   - json: json string to convert
    open class func decode<T>(_ type: T.Type, from json: Any) -> T? where T: Decodable {
        let jsonDecoder = JSONDecoder()
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) {
            return try? jsonDecoder.decode(type, from: jsonData)
        }
        return nil
    }
    
}
