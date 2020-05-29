//
//  MeteorDDP+String.swift
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


// MARK:- 🚀 MeteorDDP - String internal extension
internal extension String {
    
    /// Convert to base64 string
    var toBase64: String {
        let encodedData = (self as NSString).data(using: String.Encoding.utf8.rawValue)
        let base64String = encodedData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        return base64String as String
    }
    
    /// Convert string to KeyValue pair
    var keyValue: MeteorKeyValue {
        var keyValue: MeteorKeyValue?
        if let data = self.data(using: .utf8) {
            do {
                keyValue = try JSONSerialization.jsonObject(with: data, options: []) as? MeteorKeyValue
            } catch {
                logger.logError(.error, error.localizedDescription)
            }
        }
        if let keyValue = keyValue {
             return keyValue
        }
        return ["msg":"error",
                "reason":"MeteorDDP JSON serialization error.",
                "details": "JSON string: \(self)."]
    }
    
    /// Check for email validity
    var isValidEmail: Bool {
        let pattern = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    /// Generates random string with UUID string
    static var randomString : String {
        let numbers = Set<Character>(["0","1","2","3","4","5","6","7","8","9"])
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        var id = ""
        uuid.forEach {
            if (!numbers.contains($0) && (round(Float(arc4random()) / Float(UINT32_MAX)) == 1)) {
                id += String($0).lowercased()
            } else {
                id += String($0)
            }
        }
        return id
    }
    
    /// Generates random base64 string with UUID string
    /// - Parameter n: character limit
    static func randomBase64(_ n: Int = 20) -> String {
        
        var string = ""
        let BASE64_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"
        
        for _ in 1...n {
            let r = arc4random() % UInt32(BASE64_CHARS.count)
            let index = BASE64_CHARS.index(BASE64_CHARS.startIndex, offsetBy: Int(r))
            let c = BASE64_CHARS[index]
            string += String(c)
        }
        
        return string
    }
    
    /// Parse http url from websocket url
    var httpUrl: String {
        let path = components(separatedBy: "/websocket")[0]
        
        let components = path.components(separatedBy: "://")
        let applicationLayerProtocol = components[0]
        
        assert(applicationLayerProtocol == "ws" || applicationLayerProtocol == "wss")
        
        let domainName = components[1]
        
        if applicationLayerProtocol == "ws" {
            return "http://\(domainName)"
        }
        
        return "https://\(domainName)"
    }
    
    /// Validate websocket url
    var websocketUrl: URL {
        guard let url = URL(string: self) else {
            fatalError("\(METEOR_DDP) Invalid Websocket URL provided")
        }
        return url
    }


    
}
