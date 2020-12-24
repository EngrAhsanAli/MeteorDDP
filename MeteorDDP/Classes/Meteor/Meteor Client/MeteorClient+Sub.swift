//
//  MeteorClient+Sub.swift
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

// MARK:- 🚀 MeteorClient+Sub - interacting with basic Meteor server-side services
internal extension MeteorClient {
    
    /// Iterates over the Dictionary of subscriptions to find a subscription by name
    /// - Parameter name: name
    
    func findSubscriptionId(byName name: String) -> String? {
        subRequests[name]?.id
    }
    
    func findSubscription(byCollection name: String) -> SubHolder? {
        subCollections[name]
    }
    
    /// Sub Ready
    /// - Parameter subs: sub IDs array
    func ready(_ subs: [String]) {
        subs.forEach { id in
            if let sub = subHandler[id] {
                sub.completion?()
                subHandler[id]?.completion = nil
            }
        }
    }
    
    /// UnSub
    /// - Parameters:
    ///   - id: ID
    ///   - error: error
    func nosub(_ id: String, error: MeteorError?) {
        guard let error = error else {
            if let sub = subHandler[id] {
                sub.completion?()
            }
            return
        }
        error.log(.unsub)
    }
    
    /// Subcscrption
    /// - Parameters:
    ///   - id: ID
    ///   - name: sub name
    ///   - params: dictionary
    ///   - callback: callback
    @discardableResult
    func sub(_ id: String, name: String, params: [Any]?, collectionName: String?, callback: MeteorCollectionCallback?, completion: MeteorCompletionVoid?) -> String {
        
        var messages: [MessageOut]
        
        if let subRequest = subRequests[name] { // Previously binded messages with same callbacks
            messages = subRequest.messages
        }
        else {
            messages = [.msg(.sub), .name(name), .id(id)]
            if let p = params { messages.append(.params(p)) }
            
            subRequests[name] = SubRequest(id: id, messages: messages) // Request object from sub name
            
            let subHolder = SubHolder(name: name, collectionName: collectionName, completion: completion, callback: callback)
            subHandler[id] = subHolder
            
            if let collectionName = collectionName {
                subCollections[collectionName] = subHolder // Get id from collectionName
            }
        }
        
        userBackground.addOperation() { [weak self] in
            
            if let self = self {
                self.sendMessage(msgs: messages)
            } else {
                logger.logError(.sub, "MeteorClient destroyed or not initiated yet. Message ignored")
            }
        }
        return id
    }

    func clearSubRequestData(with id: String) {
        guard let handler = subHandler[id] else { return }
        subRequests[handler.name] = nil
        subHandler[id] = nil
    }
}

// MARK:- MeteorClient Sub for interacting with basic Meteor server-side services
public extension MeteorClient {
    
    /// Sends a subscription request to the server. If a callback is passed, the callback asynchronously runs when the client receives a 'ready' message indicating that the initial subset of documents contained in the subscription has been sent by the server.
    /// - Parameters:
    ///   - name: The name of the subscription
    ///   - params: An object containing method arguments, if any
    ///   - collectionName: The closure of events against this collection name if provided
    ///   - callback: The closure to be executed when the server sends a 'ready' message
    @discardableResult
    func subscribe(_ name: String, params: [Any]?, collectionName: String? = nil, callback: MeteorCollectionCallback? = nil, completion: MeteorCompletionVoid? = nil) -> String {
        let id = String.randomString
        logger.log(.sub, "Collection [\(name)] with id [\(id)]", .info)
        return sub(id, name: name, params: params, collectionName: collectionName, callback: callback, completion: completion)
    }

    /// Sends an unsubscribe request to the server. If a callback is passed, the callback asynchronously runs when the client receives a 'ready' message indicating that the subset of documents contained in the subscription have been removed.
    /// - Parameters:
    ///   - id: The name of the subscription
    ///   - callback: The closure to be executed when the server sends a 'ready' message
    func unsubscribe(_ id: String, completion: MeteorCompletionVoid?) {
        backgroundQueue.addOperation() {
            self.sendMessage(msgs: [.msg(.unsub), .id(id)])
        }
        subHandler[id]?.completion = completion
        logger.log(.unsub, "with id [\(id)]", .info)
    }
    
    /// UnSub All
    /// - Parameter callback: completion
    func unsubscribeAll(_ completion: MeteorCompletionVoid?) {
        subHandler.keys.forEach { unsubscribe($0, completion: completion) }
    }
    
    /// Unsubscribe Sends an unsubscribe request to the server.
    /// - Parameters:
    ///   - name: The name of the subscription
    ///   - allowRemove:  Auto remove messages after unsub
    ///   - callback: The closure to be executed when the server sends a 'ready' message
    func unsubscribe(withName name: String, allowRemove: Bool = true, callback: MeteorCompletionVoid?) {
        guard let id = findSubscriptionId(byName: name) else {
            logger.log(.unsub, "Cannot find name \(name)", .info)
            callback?()
            return
        }
        if !allowRemove {
            subHandler[id]?.callback = nil
            removeEventObservers(name, event: MeteorEvents.collection)
        }
        unsubscribe(id) {
            logger.log(.unsub, "Removed data due to unsubscribe", .info)
            self.subRequests[name] = nil
            DispatchQueue.main.async { callback?() }
        }
    }
        
        
    func unsubscribe(withCollection name: String, allowRemove: Bool = true, callback: MeteorCompletionVoid?) {
        if let sub = findSubscription(byCollection: name) {
            self.unsubscribe(withName: sub.name, allowRemove: allowRemove, callback: callback)
        }
        else {
            callback?()
        }
    }
    /// Update Collection
    /// - Parameters:
    ///   - collection: name
    ///   - type: operation type
    ///   - documents: documents data
    ///   - callback: completion
    @discardableResult
    func updateColection(_ collection: String, type: CollectionMethod, documents: [Any], callback: MeteorMethodCallback? = nil) -> String {
        let callName = "/\(collection)/\(type.rawValue)"
        return call(callName, params: documents, callback: callback)
    }
    
}
