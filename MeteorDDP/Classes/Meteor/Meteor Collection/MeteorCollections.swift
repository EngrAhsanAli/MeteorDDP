//
//  MeteorCollection.swift
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

// MARK:- 🚀 MeteorCollection - provides basic persistence as well as an api for integrating MeteorDDP with persistence stores.
open class MeteorCollections {
        
    internal var _documents = [String: MeteorKeyValue]()
    
    internal let client: MeteorClient
    
    internal var name: String!
    
    open var updateDelay: TimeInterval = 0.33
    
    open var collectionDidChange: ((MeteorCollections) -> ())?
    
    open var documents: [MeteorKeyValue] {
        return Array(_documents.values)
    }
    
    /// Returns the number of documents in the collection
    open var count: Int {
        return _documents.count
    }
    
    /// Initializes a MeteorCollection object
    /// - Parameter name: The string name of the collection (must match the name of the collection on the server)
    public init(client: MeteorClient) {
        self.client = client

    }
    
    /// Bind observers
    func bindEvents() {
        
        client.addEventObserver(name, event: .dataAdded) {
            guard let value = $0 as? MeteorDocument else {
                return
            }
            if let c = self.client.collections[self.name] {
                c.localInsert(value.id, fields: value.fields ?? [:])
            }
        }
        
        client.addEventObserver(name, event: .dataChange) {
            guard let value = $0 as? MeteorDocument else {
                return
            }
            if let c = self.client.collections[self.name] {
                c.localUpdate(value.id, updated: value.fields ?? [:], cleared: value.cleared)
            }
        }
        
        client.addEventObserver(name, event: .dataRemove) {
            guard let value = $0 as? MeteorDocument else {
                return
            }
            if let c = self.client.collections[self.name] {
                c.localRemove(value.id)
            }
        }
    }
    
    /// deinit
    deinit {
        client.removeEventObservers(name, event: MeteorEvents.collection)
        client.unsubscribeAll(nil)
        client.collections.removeAll()
    }
    
    /// Find a single document by id
    /// - Parameter id: the id of the document
    open func findOne(_ id: String) -> MeteorKeyValue? {
        return _documents[id]
    }
    
}

// MARK:- 🚀 MeteorCollection -
public extension MeteorCollections {
    
    /// Inserts local document
    /// - Parameters:
    ///   - id: ID of the document
    ///   - fields: new fields
    func localInsert(_ id: String, fields: MeteorKeyValue) {
        self._documents[id] = fields
        broadcastChange()
    }
    
    /// Updates local document
    /// - Parameters:
    ///   - id: ID of the document
    ///   - updated: updated fields
    ///   - cleared: removed fields
    func localUpdate(_ id: String, updated: MeteorKeyValue, cleared: [String]?) {
        
        if var document = _documents[id] {
            document = updated
            cleared?.forEach {
                document[$0] = nil
            }
            self._documents[id] = document
            broadcastChange()
        }
    }
    
    /// Removes local document
    /// - Parameter id: ID of the document
    func localRemove(_ id: String) {
        if let _ = _documents[id] {
            self._documents[id] = nil
            broadcastChange()
        }
    }
    
    /// Client-side method to insert a document
    /// - Parameter document: a document that inherits from MeteorDocument
    func remoteInsert(_ id: String, fields: MeteorKeyValue) {
        guard let name = name else {
            logger.log(.sub, "Call the subscribe method first")
            return
        }
        var document = fields
        localInsert(id, fields: fields)
        
        document["_id"] = id

        client.updateColection(name, type: .insert, documents: [document]) { result, error in
            if let error = error {
                error.log(.doc)
                self._documents[id] = nil
                self.broadcastChange()
            }
        }
        
    }
    
    /// Client-side method to update a document
    /// - Parameters:
    ///   - document: a document that inherits from MeteorDocument
    ///   - operation: a dictionary containing a Mongo selector and a json object
    func remoteUpdate(_ id: String, document: MeteorKeyValue, withMongoOperation operation: MeteorKeyValue) {
        guard let name = name else {
            logger.log(.sub, "Call the subscribe method first")
            return
        }
        
        let originalDocument = _documents[id]
        _documents[id] = document
        broadcastChange()
        
        client.updateColection(name, type: .update, documents: [["_id":id], operation]) { result, error in
            if let error = error {
                error.log(.doc)
                self._documents[id] = originalDocument
                self.broadcastChange()
            }
        }
    }
    
    /// Client-side method to update a document
    /// - Parameter document: a document that inherits from MeteorDocument
    func remoteUpdate(_ id: String, document: MeteorKeyValue) {
        guard let name = name else {
            logger.log(.sub, "Call the subscribe method first")
            return
        }
        let originalDocument = _documents[id]
        _documents[id] = document
        broadcastChange()
        
        client.updateColection(name, type: .update, documents: [["_id":id],["$set": document]]) { result, error in
            if let error = error {
                error.log(.doc)
                self._documents[id] = originalDocument
                self.broadcastChange()
            }
        }

    }
    
    /// Client-side method to remove a document
    /// - Parameter document: a document that inherits from MeteorDocument
    func remoteRemove(_ id: String, document: MeteorKeyValue) {
        guard let name = name else {
            logger.log(.sub, "Call the subscribe method first")
            return
        }
        localRemove(id)
        broadcastChange()

        client.updateColection(name, type: .remove, documents: [["_id":id]]) { result, error in
            if let error = error {
                error.log(.doc)
                self._documents[id] = document
                self.broadcastChange()
            }
        }
    }
}

// MARK:- 🚀 MeteorCollection -
public extension MeteorCollections {
    
    /// Subscribe
    /// - Parameters:
    ///   - name: string
    ///   - params: params
    ///   - callback: completion
    @discardableResult
    func subscribe(_ name: String, params: [Any]?, collectionName: String? = nil, callback: MeteorCollectionCallback? = nil) -> String {
        self.name = name

        unsubscribe(name)
        client.collections[name] = self
        
        bindEvents()
        return client.subscribe(name, params: params, collectionName: collectionName, callback: callback)
    }
    
    /// Unsubscribe
    /// - Parameter name: string
    func unsubscribe(_ name: String) {
        self.name = name

        if client.collections[name] != nil {
            client.unsubscribe(withName: name, callback: nil)
            client.collections[name] = nil
        }
    }
}

// MARK:- 🚀 MeteorCollection -
fileprivate extension MeteorCollections {
    
    /// Broadcast dataset change
    func broadcastChange() {
        guard let didChange = self.collectionDidChange else {
            return
        }
        updateDelay.debounce(.main) {
            OperationQueue.main.addOperation() {
                didChange(self)
            }
        }
    }
    
}
