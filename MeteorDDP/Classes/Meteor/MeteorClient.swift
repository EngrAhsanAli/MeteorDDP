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

//
// This software uses CryptoSwift: https://github.com/krzyzanowskim/CryptoSwift/
//

import Foundation
import XCGLogger
import CryptoSwift

private let syncWarning = {(name:String) -> Void in
    if Thread.isMainThread {
        print("\(name) is running synchronously on the main thread. This will block the main thread and should be run on a background thread")
    }
}


// MARK:- MeteorClient
open class MeteorClient: NSObject {
    
    // included for storing login id and token
    internal let userData = UserDefaults.standard
    
    let background: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "MeteorDDP Background Data Queue"
        queue.qualityOfService = .background
        return queue
    }()
    
    // Callbacks execute in the order they're received
    internal let callbackQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "MeteorDDP Callback Queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    // Document messages are processed in the order that they are received,
    // separately from callbacks
    internal let documentQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "MeteorDDP Background Queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()
    
    // Hearbeats get a special queue so that they're not blocked by
    // other operations, causing the connection to close
    internal let heartbeat: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "MeteorDDP Heartbeat Queue"
        queue.qualityOfService = .utility
        return queue
    }()
    
    let userBackground: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "MeteorDDP High Priority Background Queue"
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    let userMainQueue: OperationQueue = {
        let queue = OperationQueue.main
        queue.name = "MeteorDDP High Priorty Main Queue"
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    fileprivate var socket: WebSocket! {
        didSet{ socket.allowSelfSignedSSL = self.allowSelfSignedSSL }
    }
    fileprivate var server:(ping:Date?, pong:Date?) = (nil, nil)
    fileprivate var subscriptions = [String:(id:String, name:String, ready:Bool)]()

    internal var resultCallbacks:[String:CompletionWrapper] = [:]
    internal var subCallbacks:[String:CompletionWrapper] = [:]
    internal var unsubCallbacks:[String:CompletionWrapper] = [:]
    internal var events = MeteorEvents()
    internal var connection:(ddp:Bool, session:String?) = (false, nil)
    
    open var userDidLogin: MeteorConnectedCallback?
    open var userDidLogout: MeteorConnectedCallback?
    open var url:String!
    
    open var allowSelfSignedSSL:Bool = false {
        didSet{
            guard let currentSocket = socket else { return }
            currentSocket.allowSelfSignedSSL = allowSelfSignedSSL
        }
    }

    // MARK: Settings
    
    /**
    Sets the log level. The default value is .None.
    Possible values: .Verbose, .Debug, .Info, .Warning, .Error, .Severe, .None
    */
    
    open var logLevel = XCGLogger.Level.none {
        didSet {
            logger.setup(level: logLevel, showLogIdentifier: true, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: false, showLineNumbers: true, showDate: false, writeToFile: nil, fileLevel: XCGLogger.Level.none)
        }
    }
    
    internal override init() {
        super.init()
    }
    
    /**
    Creates a random String id
    */
    
    open func getId() -> String {
        let numbers = Set<Character>(["0","1","2","3","4","5","6","7","8","9"])
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        var id = ""
        for character in uuid {
            if (!numbers.contains(character) && (round(Float(arc4random()) / Float(UINT32_MAX)) == 1)) {
                id += String(character).lowercased()
            } else {
                id += String(character)
            }
        }
        return id
    }
    
    /**
     Makes a DDP connection to the server
     
     - parameter url:        The String url to connect to, ex. "wss://todos.meteor.com/websocket"
     - parameter callback:   A closure that takes a String argument with the value of the websocket session token
     */
    
    open func connect(_ url:String, callback:MeteorConnectedCallback?) {
        self.url = url
        // capture the thread context in which the function is called
        let executionQueue = OperationQueue.current
        
        socket = WebSocket(url)
        //Create backoff
        let backOff:ExponentialBackoff = ExponentialBackoff()
        
        socket.event.close = {code, reason, clean in
            //Use backoff to slow reconnection retries
            backOff.createBackoff({
                logger.info("Web socket connection closed with code \(code). Clean: \(clean). \(reason)")
                let event = self.socket.event
                self.socket = WebSocket(url)
                self.socket.event = event
                self.ping()
            })
        }
        
        socket.event.error = events.onWebsocketError
        
        socket.event.open = {
            self.heartbeat.addOperation() {
                
                // Add a subscription to loginServices to each connection event
                let callbackWithServiceConfiguration = { (session:String) in
                                        
                    let loginServiceConfiguration = "meteor.loginServiceConfiguration"
                    self.sub(loginServiceConfiguration, params: nil)           // /tools/meteor-services/auth.js line 922
                    
                    
                    // Resubscribe to existing subs on connection to ensure continuity
                    self.subscriptions.forEach({ (subscription: (String, (id: String, name: String, ready: Bool))) -> () in
                        if subscription.1.name != loginServiceConfiguration {
                            self.sub(subscription.1.id, name: subscription.1.name, params: nil, callback: nil)
                        }
                    })
                    callback?(session)
                }
                
                var completion = CompletionWrapper(connectedCallback: callbackWithServiceConfiguration)
                //Reset the backoff to original values
                backOff.reset()
                completion.executionQueue = executionQueue
                self.events.onConnected = completion
                self.sendMessage(["msg":"connect", "version":"1", "support":["1"]])
            }
        }
        
        socket.event.message = { message in
            self.background.addOperation() {
                if let text = message as? String {
                    do { try self.messageHandler(MeteorMessage(message: text)) }
                    catch { logger.debug("Message handling error. Raw message: \(text)")}
                }
            }
        }
    }
    
    fileprivate func ping() {
        heartbeat.addOperation() {
            self.sendMessage(["msg":"ping", "id":self.getId()])
        }
    }
    
    // Respond to a server ping
    fileprivate func pong(_ ping: MeteorMessage) {
        heartbeat.addOperation() {
            self.server.ping = Date()
            var response = ["msg":"pong"]
            if let id = ping.id { response["id"] = id }
            self.sendMessage(response as NSDictionary)
        }
    }
    
    // Parse DDP messages and dispatch to the appropriate function
    internal func messageHandler(_ message: MeteorMessage) throws {
        
        logger.debug("Received message: \(String(describing: message.json))")
        
        switch message.type {
            
        case .connected:
            self.connection = (true, message.session!)
            self.events.onConnected.execute(message.session!)
            
        case .result: callbackQueue.addOperation() {
            if let id = message.id,                              // Message has id
                let completion = self.resultCallbacks[id],          // There is a callback registered for the message
                let result = message.result {
                    completion.execute(result, error: message.error)
                    self.resultCallbacks[id] = nil
            } else if let id = message.id,
                let completion = self.resultCallbacks[id] {
                    completion.execute(nil, error:message.error)
                    self.resultCallbacks[id] = nil
            }
            }
            
            // Principal callbacks for managing data
            // Document was added
        case .added: documentQueue.addOperation() {
            if let collection = message.collection,
                let id = message.id {
                    self.documentWasAdded(collection, id: id, fields: message.fields)
            }
            }
            
            // Document was changed
        case .changed: documentQueue.addOperation() {
            if let collection = message.collection,
                let id = message.id {
                    self.documentWasChanged(collection, id: id, fields: message.fields, cleared: message.cleared)
            }
            }
            
            // Document was removed
        case .removed: documentQueue.addOperation() {
            if let collection = message.collection,
                let id = message.id {
                    self.documentWasRemoved(collection, id: id)
            }
            }
            
            // Notifies you when the result of a method changes
        case .updated: documentQueue.addOperation() {
            if let methods = message.methods {
                self.methodWasUpdated(methods)
            }
            }
            
            // Callbacks for managing subscriptions
        case .ready: documentQueue.addOperation() {
            if let subs = message.subs {
                self.ready(subs)
            }
            }
            
            // Callback that fires when subscription has been completely removed
            //
        case .nosub: documentQueue.addOperation() {
            if let id = message.id {
                self.nosub(id, error: message.error)
            }
        }
            
        case .ping: heartbeat.addOperation() { self.pong(message) }
            
        case .pong: heartbeat.addOperation() { self.server.pong = Date() }
            
        case .error: background.addOperation() {
            self.didReceiveErrorMessage(MeteorError(json: message.json))
            }
            
        default: logger.error("Unhandled message: \(String(describing: message.json))")
            
        }
    }
    
    fileprivate func sendMessage(_ message:NSDictionary) {
        if let m = message.stringValue {
            self.socket.send(m)
        }
    }
    
    /**
     Executes a method on the server. If a callback is passed, the callback is asynchronously
     executed when the method has completed. The callback takes two arguments: result and error. It
     the method call is successful, result contains the return value of the method, if any. If the method fails,
     error contains information about the error.
     
     - parameter name:       The name of the method
     - parameter params:     An object containing method arguments, if any
     - parameter callback:   The closure to be executed when the method has been executed
     */
    
    @discardableResult open func method(_ name: String, params: Any?, callback: MeteorMethodCallback?) -> String {
        let id = getId()
        let message = ["msg":"method", "method":name, "id":id] as NSMutableDictionary
        if let p = params { message["params"] = p }
        
        if let completionCallback = callback {
            let completion = CompletionWrapper(methodCallback: completionCallback)
            self.resultCallbacks[id] = completion
        }
        
        userBackground.addOperation() {
            self.sendMessage(message)
        }
        return id
    }
    
    //
    // Subscribe
    //
    
    @discardableResult internal func sub(_ id: String, name: String, params: [Any]?, callback: MeteorCallback?) -> String {
        
        if let completionCallback = callback {
            let completion = CompletionWrapper(callback: completionCallback)
            self.subCallbacks[id] = completion
        }
        
        self.subscriptions[id] = (id, name, false)
        let message = ["msg":"sub", "name":name, "id":id] as NSMutableDictionary
        if let p = params { message["params"] = p }
        userBackground.addOperation() {
            [weak self] in
            
            if let strongSelf = self
            {
                strongSelf.sendMessage(message)
            } else {
                logger.error("Ignored message - client was already destroyed")
            }
        }
        return id
    }
    
    /**
     Sends a subscription request to the server.
     
     - parameter name:       The name of the subscription
     - parameter params:     An object containing method arguments, if any
     */
    
    @discardableResult open func sub(_ name: String, params: [Any]?) -> String {
        let id = getId()
        return sub(id, name: name, params: params, callback:nil)
    }
    
    /**
     Sends a subscription request to the server. If a callback is passed, the callback asynchronously
     runs when the client receives a 'ready' message indicating that the initial subset of documents contained
     in the subscription has been sent by the server.
     
     - parameter name:       The name of the subscription
     - parameter params:     An object containing method arguments, if any
     - parameter callback:   The closure to be executed when the server sends a 'ready' message
     */
    
    open func sub(_ name:String, params: [Any]?, callback: MeteorCallback?) -> String {
        let id = getId()
        logger.info("Subscribing to ID \(id)")
        return sub(id, name: name, params: params, callback: callback)
    }
    
    // Iterates over the Dictionary of subscriptions to find a subscription by name
    internal func findSubscription(_ name:String) -> [String] {
        var subs:[String] = []
        for sub in  subscriptions.values {
            if sub.name == name {
                subs.append(sub.id)
            }
        }
        return subs
    }
    
    // Iterates over the Dictionary of subscriptions to find a subscription by name
    internal func subscriptionReady(_ name:String) -> Bool {
        for sub in  subscriptions.values {
            if sub.name == name {
                return sub.ready
            }
        }
        return false
    }
    
    //
    // Unsubscribe
    //
    
    /**
     Sends an unsubscribe request to the server.
     - parameter name:       The name of the subscription
     - parameter callback:   The closure to be executed when the server sends a 'ready' message
     */
    
    open func unsub(withName name: String, callback: MeteorCallback?) -> [String] {
        
        let unsubgroup = DispatchGroup()
        
        let unsub_ids = findSubscription(name).map({id -> (String) in
            unsubgroup.enter()
            unsub(withId: id){
                unsubgroup.leave()
            }
            return id
        })
        
        if let completionCallback = callback {
            unsubgroup.notify(queue: DispatchQueue.main, execute: completionCallback)
        }
        
        return unsub_ids
    }
    
    /**
     Sends an unsubscribe request to the server. If a callback is passed, the callback asynchronously
     runs when the client receives a 'ready' message indicating that the subset of documents contained
     in the subscription have been removed.
     
     - parameter name:       The name of the subscription
     - parameter callback:   The closure to be executed when the server sends a 'ready' message
     */
    
    open func unsub(withId id: String, callback: MeteorCallback?) {
        if let completionCallback = callback {
            let completion = CompletionWrapper(callback: completionCallback)
            unsubCallbacks[id] = completion
        }
        background.addOperation() { self.sendMessage(["msg":"unsub", "id":id]) }
    }
    
    //
    // Responding to server subscription messages
    //
    
    fileprivate func ready(_ subs: [String]) {
        for id in subs {
            if let completion = subCallbacks[id] {
                completion.execute()                // Run the callback
                subCallbacks[id] = nil              // Delete the callback after running
            } else {                                // If there is no callback, execute the method
                if var sub = subscriptions[id] {
                    sub.ready = true
                    subscriptions[id] = sub
                    subscriptionIsReady(sub.id, subscriptionName: sub.name)
                }
            }
        }
    }
    
    fileprivate func nosub(_ id: String, error: MeteorError?) {
        if let e = error, (e.isValid == true) {
            logger.error("\(e)")
        } else {
            if let completion = unsubCallbacks[id],
                let _ = subscriptions[id] {
                    completion.execute()
                    unsubCallbacks[id] = nil
                    subscriptions[id] = nil
            } else {
                if let subscription = subscriptions[id] {
                    subscriptions[id] = nil
                    subscriptionWasRemoved(subscription.id, subscriptionName: subscription.name)
                }
            }
        }
    }
    
    //
    // public callbacks: should be overridden
    //
    
    /**
    Executes when a subscription is ready.
    
    - parameter subscriptionId:             A String representation of the hash of the subscription name
    - parameter subscriptionName:           The name of the subscription
    */
    
    open func subscriptionIsReady(_ subscriptionId: String, subscriptionName:String) {}
    
    /**
     Executes when a subscription is removed.
     
     - parameter subscriptionId:             A String representation of the hash of the subscription name
     - parameter subscriptionName:           The name of the subscription
     */
    
    open func subscriptionWasRemoved(_ subscriptionId:String, subscriptionName:String) {}
    
    
    /**
     Executes when the server has sent a new document.
     
     - parameter collection:                 The name of the collection that the document belongs to
     - parameter id:                         The document's unique id
     - parameter fields:                     The documents properties
     */
    
    open func documentWasAdded(_ collection:String, id:String, fields:NSDictionary?) {
        if let added = events.onAdded { added(collection, id, fields) }
    }
    
    /**
     Executes when the server sends a message to remove a document.
     
     - parameter collection:                 The name of the collection that the document belongs to
     - parameter id:                         The document's unique id
     */
    
    open func documentWasRemoved(_ collection:String, id:String) {
        if let removed = events.onRemoved { removed(collection, id) }
    }
    
    /**
     Executes when the server sends a message to update a document.
     
     - parameter collection:                 The name of the collection that the document belongs to
     - parameter id:                         The document's unique id
     - parameter fields:                     Optional object with EJSON values containing the fields to update
     - parameter cleared:                    Optional array of strings (field names to delete)
     */
    
    open func documentWasChanged(_ collection:String, id:String, fields:NSDictionary?, cleared:[String]?) {
        if let changed = events.onChanged { changed(collection, id, fields, cleared as NSArray?) }
    }
    
    /**
     Executes when the server sends a message indicating that the result of a method has changed.
     
     - parameter methods:                    An array of strings (ids passed to 'method', all of whose writes have been reflected in data messages)
     */
    
    open func methodWasUpdated(_ methods:[String]) {
        if let updated = events.onUpdated { updated(methods) }
    }
    
    /**
     Executes when the client receives an error message from the server. Such a message is used to represent errors raised by the method or subscription, as well as an attempt to subscribe to an unknown subscription or call an unknown method.
     
     - parameter message:                    A DDPError object with information about the error
     */
    
    open func didReceiveErrorMessage(_ message: MeteorError) {
        if let error = events.onError { error(message) }
    }
}

/**
Extensions that provide an api for interacting with basic Meteor server-side services
*/

extension MeteorClient {
    
    /**
    Sends a subscription request to the server.
    
    - parameter name:       The name of the subscription
    */
    
    public func subscribe(_ name:String) -> String { return sub(name, params:nil) }
    
    /**
    Sends a subscription request to the server.
    
    - parameter name:       The name of the subscription
    - parameter params:     An object containing method arguments, if any
    */
    
    public func subscribe(_ name:String, params:[Any]) -> String { return sub(name, params:params) }
    
    /**
    Sends a subscription request to the server. If a callback is passed, the callback asynchronously
    runs when the client receives a 'ready' message indicating that the initial subset of documents contained
    in the subscription has been sent by the server.
    
    - parameter name:       The name of the subscription
    - parameter params:     An object containing method arguments, if any
    - parameter callback:   The closure to be executed when the server sends a 'ready' message
    */
    
    public func subscribe(_ name:String, params:[Any]?, callback: MeteorCallback?) -> String { return sub(name, params:params, callback:callback) }
    
    /**
    Sends a subscription request to the server. If a callback is passed, the callback asynchronously
    runs when the client receives a 'ready' message indicating that the initial subset of documents contained
    in the subscription has been sent by the server.
    
    - parameter name:       The name of the subscription
    - parameter callback:   The closure to be executed when the server sends a 'ready' message
    */
    
    public func subscribe(_ name:String, callback: MeteorCallback?) -> String { return sub(name, params:nil, callback:callback) }
    
    
    /**
    Asynchronously inserts a document into a collection on the server
    
    - parameter collection: The name of the collection
    - parameter document:   An NSArray of documents to insert
    - parameter callback:   A closure with result and error arguments describing the result of the operation
    */
    
    @discardableResult public func insert(_ collection: String, document: NSArray, callback: MeteorMethodCallback?) -> String {
        let arg = "/\(collection)/insert"
        return self.method(arg, params: document, callback: callback)
    }
    
    /**
    Asynchronously inserts a document into a collection on the server
    
    - parameter collection: The name of the collection
    - parameter document:   An NSArray of documents to insert
    */
    
    @discardableResult
    public func insert(_ collection: String, document: NSArray) -> String {
        return insert(collection, document: document, callback:nil)
    }
    
    /**
    Synchronously inserts a document into a collection on the server. Cannot be used on the main queue.
    
    - parameter collection: The name of the collection
    - parameter document:   An NSArray of documents to insert
    */
    
    public func insert(sync collection: String, document: NSArray) -> MeteorResponse {
        
        syncWarning("Insert")
        
        let semaphore = DispatchSemaphore(value: 0)
        var serverResponse = MeteorResponse()
        
        insert(collection, document:document) { result, error in
            serverResponse.result = result
            serverResponse.error = error
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: callbackDispatchTime)
        
        return serverResponse
    }
    
    /**
    Asynchronously updates a document into a collection on the server
    
    - parameter collection: The name of the collection
    - parameter document:   An NSArray of documents to update
    - parameter callback:   A closure with result and error arguments describing the result of the operation
    */
    
    @discardableResult public func update(_ collection: String, document: NSArray, callback: MeteorMethodCallback?) -> String {
        let arg = "/\(collection)/update"
        return method(arg, params: document, callback: callback)
    }
    
    /**
    Asynchronously updates a document on the server
    
    - parameter collection: The name of the collection
    - parameter document:   An NSArray of documents to update
    */
    @discardableResult
    public func update(_ collection: String, document: NSArray) -> String {
        return update(collection, document: document, callback:nil)
    }
    
    /**
    Synchronously updates a document on the server. Cannot be used on the main queue
    
    - parameter collection: The name of the collection
    - parameter document:   An NSArray of documents to update
    */
    
    public func update(sync collection: String, document: NSArray) -> MeteorResponse {
        syncWarning("Update")
        
        let semaphore = DispatchSemaphore(value: 0)
        var serverResponse = MeteorResponse()
        
        update(collection, document:document) { result, error in
            serverResponse.result = result
            serverResponse.error = error
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: callbackDispatchTime)
        
        return serverResponse
    }
    
    /**
    Asynchronously removes a document on the server
    
    - parameter collection: The name of the collection
    - parameter document:   An NSArray of documents to remove
    - parameter callback:   A closure with result and error arguments describing the result of the operation
    */
    
    @discardableResult public func remove(_ collection: String, document: NSArray, callback: MeteorMethodCallback?) -> String {
        let arg = "/\(collection)/remove"
        return method(arg, params: document, callback: callback)
    }
    
    /**
    Asynchronously removes a document into a collection on the server
    
    - parameter collection: The name of the collection
    - parameter document:   An NSArray of documents to remove
    */
    @discardableResult
    public func remove(_ collection: String, document: NSArray) -> String  {
        return remove(collection, document: document, callback:nil)
    }
    
    /**
    Synchronously removes a document into a collection on the server. Cannot be used on the main queue.
    
    - parameter collection: The name of the collection
    - parameter document:   An NSArray of documents to remove
    */
    
    public func remove(sync collection: String, document: NSArray) -> MeteorResponse {
        syncWarning("Remove")
        
        let semaphore = DispatchSemaphore(value: 0)
        var serverResponse = MeteorResponse()
        
        remove(collection, document:document) { result, error in
            serverResponse.result = result
            serverResponse.error = error
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: callbackDispatchTime)
        
        return serverResponse
    }
    
    // Callback runs on main thread
    public func login(_ params: NSDictionary, callback: ((_ result: Any?, _ error: MeteorError?) -> ())?) {
        
        // method is run on the userBackground queue
        method("login", params: NSArray(arrayLiteral: params)) { result, error in
            guard let e = error, (e.isValid == true) else {
                
                if let user = params["user"] as? NSDictionary {
                    if let email = user["email"] {
                        
                        self.userData.set(email, forKey: MeteorUser.DDP_EMAIL.rawValue)
                    }
                    if let username = user["username"] {
                        self.userData.set(username, forKey: MeteorUser.DDP_USERNAME.rawValue)
                    }
                }
                
                if let data = result as? NSDictionary,
                    let id = data["id"] as? String,
                    let token = data["token"] as? String,
                    let tokenExpires = data["tokenExpires"] as? NSDictionary {
                    let expiration = tokenExpires.dateFromTimestamp
                    self.userData.set(id, forKey: MeteorUser.DDP_ID.rawValue)
                    self.userData.set(token, forKey: MeteorUser.DDP_TOKEN.rawValue)
                    self.userData.set(expiration, forKey: MeteorUser.DDP_TOKEN_EXPIRES.rawValue)
                }
                
                self.userMainQueue.addOperation() {
                    
                    if let c = callback { c(result, error) }
                    self.userData.set(true, forKey: MeteorUser.DDP_LOGGED_IN.rawValue)
                    
                    NotificationCenter.post(.userDidLogin)

                    if let user = self.user() {
                        self.userDidLogout?(user)
                    }
                    
                }
                
                return
            }
            
            logger.debug("Login error: \(e)")
            if let c = callback { c(result, error) }
        }
    }

    /**
    Logs a user into the server using an email and password
    
    - parameter email:      An email string
    - parameter password:   A password string
    - parameter callback:   A closure with result and error parameters describing the outcome of the operation
    */
    
    public func loginWithPassword(_ email: String, password: String, callback: MeteorMethodCallback?) {
        if !(loginWithToken(callback)) {
            let params = ["user": ["email": email], "password":["digest": password.sha256(), "algorithm":"sha-256"]] as NSDictionary
            login(params, callback: callback)
        }
    }
    
    /**
     Logs a user into the server using a username and password
     
     - parameter username:   A username string
     - parameter password:   A password string
     - parameter callback:   A closure with result and error parameters describing the outcome of the operation
     */
    
    public func loginWithUsername(_ username: String, password: String, callback: MeteorMethodCallback?) {
        if !(loginWithToken(callback)) {
            let params = ["user": ["username": username], "password":["digest": password.sha256(), "algorithm":"sha-256"]] as NSDictionary
            login(params, callback: callback)
        }
    }
    
    /**
    Attempts to login a user with a token, if one exists
    
    - parameter callback:   A closure with result and error parameters describing the outcome of the operation
    */
    
    @discardableResult public func loginWithToken(_ callback: MeteorMethodCallback?) -> Bool {
        if let token = userData.string(forKey: MeteorUser.DDP_TOKEN.rawValue),
            let tokenDate = userData.object(forKey: MeteorUser.DDP_TOKEN_EXPIRES.rawValue) as? Date {
                print("Found token & token expires \(token), \(tokenDate)")
                if (tokenDate.compare(Date()) == ComparisonResult.orderedDescending) {
                    let params = ["resume":token] as NSDictionary
                    login(params, callback:callback)
                    return true
                }
        }
        return false
    }
    
    
    public func signup(_ params:NSDictionary, callback:((_ result: Any?, _ error: MeteorError?) -> ())?) {
        method("createUser", params: NSArray(arrayLiteral: params)) { result, error in
            guard let e = error, (e.isValid == true) else {
                
                if let email = params["email"] {
                    self.userData.set(email, forKey: MeteorUser.DDP_EMAIL.rawValue)
                }
                
                if let username = params["username"] {
                    self.userData.set(username, forKey: MeteorUser.DDP_USERNAME.rawValue)
                }
                
                if let data = result as? NSDictionary,
                    let id = data["id"] as? String,
                    let token = data["token"] as? String,
                    let tokenExpires = data["tokenExpires"] as? NSDictionary {
                    let expiration = tokenExpires.dateFromTimestamp
                    self.userData.set(id, forKey: MeteorUser.DDP_ID.rawValue)
                    self.userData.set(token, forKey: MeteorUser.DDP_TOKEN.rawValue)
                    self.userData.set(expiration, forKey: MeteorUser.DDP_TOKEN_EXPIRES.rawValue)
                        self.userData.synchronize()
                }
                if let c = callback { c(result, error) }
                self.userData.set(true, forKey: MeteorUser.DDP_LOGGED_IN.rawValue)
                return
            }
            
            logger.debug("login error: \(e)")
            if let c = callback { c(result, error) }
        }
    }
    /**
    Invokes a Meteor method to create a user account with a given email and password on the server
    
    */
    
    public func signupWithEmail(_ email: String, password: String, callback: ((_ result:Any?, _ error:MeteorError?) -> ())?) {
        let params = ["email":email, "password":["digest":password.sha256(), "algorithm":"sha-256"]] as [String : Any]
        signup(params as NSDictionary, callback: callback)
    }
    
    /**
    Invokes a Meteor method to create a user account with a given email and password, and a NSDictionary containing a user profile
    */
    
    public func signupWithEmail(_ email: String, password: String, profile: NSDictionary, callback: ((_ result:Any?, _ error:MeteorError?) -> ())?) {
        let params = ["email":email, "password":["digest":password.sha256(), "algorithm":"sha-256"], "profile":profile] as [String : Any]
        signup(params as NSDictionary, callback: callback)
    }
    
    /**
     Invokes a Meteor method to create a user account with a given username, email and password, and a NSDictionary containing a user profile
     */
    
    public func signupWithUsername(_ username: String, password: String, email: String?, profile: NSDictionary?, callback: ((_ result:Any?, _ error:MeteorError?) -> ())?) {
        let params: NSMutableDictionary = ["username":username, "password":["digest":password.sha256(), "algorithm":"sha-256"]]
        if let email = email {
            params.setValue(email, forKey: "email")
        }
        if let profile = profile {
            params.setValue(profile, forKey: "profile")
        }
        signup(params, callback: callback)
    }
    
    /**
    Returns the client userId, if it exists
    */
    
    public func userId() -> String? {
        return self.userData.object(forKey: MeteorUser.DDP_ID.rawValue) as? String
    }
    
    /**
    Returns the client's username or email, if it exists
    */
    
    public func user() -> String? {
        if let username = self.userData.object(forKey: MeteorUser.DDP_USERNAME.rawValue) as? String {
            return username
        } else if let email = self.userData.object(forKey: MeteorUser.DDP_EMAIL.rawValue) as? String {
            return email
        }
        return nil
    }
    
    
    internal func resetUserData() {
        self.userData.set(false, forKey: MeteorUser.DDP_LOGGED_IN.rawValue)
        self.userData.removeObject(forKey: MeteorUser.DDP_ID.rawValue)
        self.userData.removeObject(forKey: MeteorUser.DDP_EMAIL.rawValue)
        self.userData.removeObject(forKey: MeteorUser.DDP_USERNAME.rawValue)
        self.userData.removeObject(forKey: MeteorUser.DDP_TOKEN.rawValue)
        self.userData.removeObject(forKey: MeteorUser.DDP_TOKEN_EXPIRES.rawValue)
        self.userData.synchronize()
    }
    
    /**
    Logs a user out and removes their account data from NSUserDefaults
    */

    public func logout() {
        logout(nil)
    }
    
    /**
    Logs a user out and removes their account data from NSUserDefaults.
    When it completes, it posts a notification: DDP_USER_DID_LOGOUT on the main queue
    
    - parameter callback:   A closure with result and error parameters describing the outcome of the operation
    */
    
    public func logout(_ callback:MeteorMethodCallback?) {
        method("logout", params: nil) { result, error in
                if let error = error {
                    logger.error("\(error)")
                } else {
                    self.userMainQueue.addOperation() {
                        if let user = self.user() {
                            self.userDidLogin?(user)
                        }
                        self.resetUserData()
                        NotificationCenter.post(.userDidLogout)
                    }
                }
                callback?(result, error)
            }
        }
    
    /**
    Automatically attempts to resume a prior session, if one exists
    
    - parameter url:        The server url
    */
    
    public func resume(_ url:String, callback:MeteorCallback?) {
        connect(url) { session in
            if let _ = self.user() {
                if !self.loginWithToken() { result, error in
                    if error == nil {
                        logger.debug("Resumed previous session at launch")
                        if let completion = callback { completion() }
                    } else {
                        self.logout()
                        logger.error("\(String(describing: error))")
                        callback?()
                    }
                    }{
                    self.logout()
                    callback?()
                }
            } else {
                if let completion = callback { completion() }
            }
        }
    }
    
    /**
    Connects and logs in with an email address and password in one action
    
    - parameter url:        String url, ex. wss://todos.meteor.com/websocket
    - parameter email:      String email address
    - parameter password:   String password
    - parameter callback:   A closure with result and error parameters describing the outcome of the operation
    */
    
    public convenience init(url: String, email: String, password: String, callback: MeteorMethodCallback?) {
        self.init()
        connect(url) { session in
            self.loginWithPassword(email, password: password, callback:callback)
        }
    }
    
    /**
    Returns true if the user is logged in, and false otherwise
    */
    
    public func loggedIn() -> Bool {
        if let userLoggedIn = self.userData.object(forKey: MeteorUser.DDP_LOGGED_IN.rawValue) as? Bool, (userLoggedIn == true) {
            return true
        }
        return false
    }
    
    
}
