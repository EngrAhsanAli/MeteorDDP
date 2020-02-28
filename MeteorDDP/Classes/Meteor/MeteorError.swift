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

// MARK:- MeteorError
// A struct encapsulating a DDP error message
public struct MeteorError: Error {
    
    fileprivate var json:NSDictionary?
    
    public var error:String? { return json?["error"] as? String }
    
    public var reason:String? { return json?["reason"] as? String }
    
    public var details:String? { return json?["details"] as? String }
    
    public var offendingMessage:String? { return json?["offendingMessage"] as? String }
    
    var isValid:Bool {
        if let _ = error { return true }
        if let _ = reason { return true }
        return false
    }
    
    init(json:Any?) {
        self.json = json as? NSDictionary
    }
}
