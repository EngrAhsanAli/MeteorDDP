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

// MARK:- MeteorCollection protocol declaration is necessary
// MeteorCollection provides basic persistence as well as an api for integrating MeteorDDP with persistence stores.
open class MeteorCollection<T:MeteorDocument>: AbstractCollection {
    
    let collectionSetDidChange = debounce(TimeInterval(0.33), queue: DispatchQueue.main, action: {
        OperationQueue.main.addOperation() {
            NotificationCenter.post(.collectionDidChange)
        }
    })
    
    var documents = [String:T]()
    
    open var sorted:[T] {
        return Array(documents.values).sorted(by: { $0._id > $1._id })
    }
    
    /// Returns the number of documents in the collection
    open var count:Int {
        return documents.count
    }
    
    /// Initializes a MeteorCollection object
    /// - Parameter name: The string name of the collection (must match the name of the collection on the server)
    public override init(name: String) {
        super.init(name: name)
    }
    
    fileprivate func index(_ id: String) -> Int? {
        return sorted.firstIndex(where: {item in item._id == id})
    }
    
    fileprivate func sorted(_ property:String) -> [T] {
        let values = Array(documents.values)
        return values.sorted(by: { $0._id > $1._id })
    }
    
    /// Find a single document by id
    /// - Parameter id: the id of the document
    open func findOne(_ id: String) -> T? {
        return documents[id]
    }
    
    /// Invoked when a document has been sent from the server.
    /// - Parameters:
    ///   - collection: the string name of the collection to which the document belongs
    ///   - id: the string unique id that identifies the document on the server
    ///   - fields: an optional NSDictionary with the documents properties
    open override func documentWasAdded(_ collection:String, id:String, fields:NSDictionary?) {
        let document = T(id: id, fields: fields)
        self.documents[id] = document
        collectionSetDidChange()
    }
    
    /// Invoked when a document has been changed on the server.
    /// - Parameters:
    ///   - collection: the string name of the collection to which the document belongs
    ///   - id: the string unique id that identifies the document on the server
    ///   - fields: an optional NSDictionary with the documents properties
    ///   - cleared: Optional array of strings (field names to delete)
    open override func documentWasChanged(_ collection:String, id:String, fields:NSDictionary?, cleared:[String]?) {
        if let document = documents[id] {
            document.update(fields, cleared: cleared)
            self.documents[id] = document
            collectionSetDidChange()
        }
    }
    
    /// Invoked when a document has been removed on the server.
    /// - Parameters:
    ///   - collection: the string name of the collection to which the document belongs
    ///   - id: the string unique id that identifies the document on the server
    open override func documentWasRemoved(_ collection:String, id:String) {
        if let _ = documents[id] {
            self.documents[id] = nil
            collectionSetDidChange()
        }
    }
    
    /// Client-side method to insert a document
    /// - Parameter document: a document that inherits from MeteorDocument
    open func insert(_ document: T) {
        
        documents[document._id] = document
        collectionSetDidChange()

        client.insert(self.name, document: [document.fields()]) { result, error in
            
            if error != nil {
                self.documents[document._id] = nil
                self.collectionSetDidChange()
                logger.error("\(error!)")
            }
            
        }
        
    }
    
    /// Client-side method to update a document
    /// - Parameters:
    ///   - document: a document that inherits from MeteorDocument
    ///   - operation: a dictionary containing a Mongo selector and a json object
    open func update(_ document: T, withMongoOperation operation: [String:Any]) {
        let originalDocument = documents[document._id]
        
        documents[document._id] = document
        collectionSetDidChange()
        
        client.update(self.name, document: [["_id":document._id], operation]) { result, error in
            
            if error != nil {
                self.documents[document._id] = originalDocument
                self.collectionSetDidChange()
                logger.error("\(error!)")
            }
            
        }
    }
    
    /// Client-side method to update a document
    /// - Parameter document: a document that inherits from MeteorDocument
    open func update(_ document: T) {
        
        let originalDocument = documents[document._id]
        
        documents[document._id] = document
        collectionSetDidChange()

        let fields = document.fields()
        
        client.update(self.name, document: [["_id":document._id],["$set":fields]]) { result, error in
            
            if error != nil {
                self.documents[document._id] = originalDocument
                self.collectionSetDidChange()
                logger.error("\(error!)")
            }
            
        }
        
    }
    
    /// Client-side method to remove a document
    /// - Parameter document: a document that inherits from MeteorDocument
    open func remove(_ document: T) {
        documents[document._id] = nil
        collectionSetDidChange()

        client.remove(self.name, document: [["_id":document._id]]) { result, error in
            
            if error != nil {
                self.documents[document._id] = document
                self.collectionSetDidChange()
                logger.error("\(error!)")
            }
            
        }
    }
}

    
