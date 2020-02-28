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

// MARK:- MeteorCollectionType
public protocol MeteorCollectionType {
    func documentWasAdded(_ collection:String, id:String, fields:NSDictionary?)
    func documentWasChanged(_ collection:String, id:String, fields:NSDictionary?, cleared:[String]?)
    func documentWasRemoved(_ collection:String, id:String)
}

// MARK:- AbstractCollection
open class AbstractCollection: NSObject, MeteorCollectionType {
    
    open var name:String
    public let client = Meteor.client
    
    public init(name:String) {
        self.name = name
        super.init()
        Meteor.collections[name] = self
    }
    
    deinit {
        Meteor.collections[name] = nil
    }
    
    open func documentWasAdded(_ collection:String, id:String, fields:NSDictionary?) {}
    
    open func documentWasChanged(_ collection:String, id:String, fields:NSDictionary?, cleared:[String]?) {}
    
    open func documentWasRemoved(_ collection:String, id:String) {}
    
}
