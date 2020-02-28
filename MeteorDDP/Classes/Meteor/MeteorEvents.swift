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

// MARK:- MeteorEvents
// DDPEvents is a struct holder for callback closures that execute in response to websocket and Meteor lifecyle events. New closures can be assigned to public closures to modify the clients behavior in response to the trigger event.
public struct MeteorEvents {
    
    /**
    onWebsocketClose executes when the websocket connection has closed
    
    - parameter code:       An integer value that provides the reason code for closing the websocket connection
    - parameter reason:     A string describing the reason that the websocket was closed
    - parameter clean:      A boolean value indicating if the websocket connection was closed cleanly
    */
    
    internal var onWebsocketClose: ((_ code:Int, _ reason:String, _ clean:Bool) -> ())? = { code, reason, clean in
        NotificationCenter.post(.socketDidClose)
    }
    
    /**
    onWebsocketError executes when the websocket connection returns an error.
    
    - parameter error:      An ErrorType object describing the error
    */
    
    internal var onWebsocketError: (_ error:Error) -> () = {error in
        logger.error("websocket error \(error)")
        NotificationCenter.post(.socketError)
    }
    
    /**
    onConnected executes when the client makes a DDP connection
    
    - parameter session:    A string session id
    */
    
    // public var onConnected:         (session:String) -> () = {session in log.info("connected with session: \(session)")}
    public var onConnected: CompletionWrapper = CompletionWrapper { session in logger.info("connected with session: \(session)")}

    /**
    onDisconnected executes when the client is disconnected
    */
    
    public var onDisconnected: () -> () = {
        logger.debug("disconnected")
        NotificationCenter.post(.socketDidDisconnected)
        
    }
    
    /**
    onFailed executes when an attempt to make a DDP connection fails
    */
    
    public var onFailed: () -> () = {
        logger.error("failed")
        NotificationCenter.post(.socketFailed)
    }
    
    // Data messages
    
    /**
    onAdded executes when a document has been added to a local collection
    
    - parameter collection:     the string name of the collection to which the document belongs
    - parameter id:             the string unique id that identifies the document on the server
    - parameter fields:         an optional NSDictionary with the documents properties
    */
    
    public var onAdded: ((_ collection:String, _ id:String, _ fields:NSDictionary?) -> ())?
    
    /**
    onChanged executes when the server sends an instruction to modify a local document
    
    
    - parameter collection:     the string name of the collection to which the document belongs
    - parameter id:             the string unique id that identifies the document on the server
    - parameter fields:         an optional NSDictionary with the documents properties
    - parameter cleared:        an optional array of string property names to delete
    */
    
    public var onChanged: ((_ collection:String, _ id:String, _ fields:NSDictionary?, _ cleared:NSArray?) -> ())?
    
    /**
    onRemoved executes when the server sends an instruction to remove a document from the local collection
    
    - parameter collection:     the string name of the collection to which the document belongs
    - parameter id:             the string unique id that identifies the document on the server
    */
    
    public var onRemoved: ((_ collection:String, _ id:String) -> ())?
    
    // RPC Messages
    // public var onResult:            (json: NSDictionary?, callback:(result:Any?, error:Any?) -> ()) -> () = {json, callback in callback(result: json, error:nil) }
    
    /**
    onUpdated executes when the server sends a notification that all the consequences of a method call have
    been communicated to the client
    
    - parameter methods:    An array of method id strings
    */
    
    public var onUpdated: ((_ methods: [String]) -> ())?
    
    /**
    onError executes when the client receives a DDP error message
    
    - parameter message:    A DDPError message describing the error
    */
    
    public var onError: ((_ message:MeteorError) -> ())?
    
}

