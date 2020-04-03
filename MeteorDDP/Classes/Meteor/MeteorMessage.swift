//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// MARK:- MeteorMessage
// A struct to parse, encapsulate and facilitate handling of DDP message strings

public struct MeteorMessage {
    
    public var json: NSDictionary!
    
    public init(message:String) {
        
        if let JSON = message.dictionaryValue { json = JSON }
        else {
            json = ["msg":"error", "reason":"MeteorDDP JSON serialization error.",
                "details": "MeteorDDP JSON serialization error. JSON string was: \(message). Message will be handled as a DDP message error."]
        }
    }
    
    public init(message:[String:String]) {
        json = message as NSDictionary
    }
    
    public var type:MeteorMessageType {
        if let msg = message,
            let type = MeteorMessageType(rawValue: msg) {
                return type
        }
        return MeteorMessageType(rawValue: "unhandled")!
    }
    
    public var isError:Bool {
        if (self.type == .error) { return true }
        if let _ = self.error { return true }
        return false
    }
    
    // Returns the root-level keys of the JSON object
    internal var keys:[String] {
        return json.allKeys as! [String]
    }
    
    public func hasProperty(_ name:String) -> Bool {
        if let property = json[name], ((property as! NSObject) != NSNull()) {
            return true
        }
        return false
    }
    
    public var message:String? {
        get { return json["msg"] as? String }
    }
    
    public var session:String? {
        get { return json["session"] as? String }
    }
    
    public var version:String? {
        get { return json["version"] as? String }
    }
    
    public var support:String? {
        get { return json["support"] as? String }
    }
    
    public var id:String? {
        get { return json["id"] as? String }
    }
    
    public var name:String? {
        get { return json["name"] as? String }
    }
    
    public var params:String? {
        get { return json["params"] as? String }
    }
    
    public var error:MeteorError? {
        get { if let e = json["error"] as? NSDictionary { return MeteorError(json:e) } else { return nil }}
    }
    
    public var collection:String? {
        get { return json["collection"] as? String }
    }
    
    public var fields:NSDictionary? {
        get { return json["fields"] as? NSDictionary }
    }
    
    public var cleared:[String]? {
        get { return json["cleared"] as? [String] }
    }
    
    public var method:String? {
        get { return json["method"] as? String }
    }
    
    public var randomSeed:String? {
        get { return json["randomSeed"] as? String }
    }
    
    public var result:Any? {
        get { return json.object(forKey: "result") as Any? }
    }
    
    public var methods:[String]? {
        get { return json["methods"] as? [String] }
    }
    
    public var subs:[String]? {
        get { return json["subs"] as? [String] }
    }
    
    public var reason:String? {
        get { return json["reason"] as? String }
    }
    
    public var offendingMessage:String? {
        get { return json["offendingMessage"] as? String }
    }
}


