//
//  MeteorClient+Events.swift
//  MeteorDDP
//
//  Created by Muhammad Ahsan Ali on 2020/04/21.
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

// MARK:- 🚀 Meteor Events - Enums to handle all events
public enum MeteorEvents: String {
    case method, websocket
    case dataAdded, dataChange, dataRemove
    
}

public extension MeteorEvents {
    static var collection: [MeteorEvents] {
        return [.dataAdded, .dataChange, .dataRemove]
    }
}

// MARK:- WebSocketEvent
public enum WebSocketEvent {
    case connected, disconnected
    case text(String)
    case error(Error?)
}

// MARK:- MeteorResponse
public class MeteorResponse {
    public let name: String
    init(_ name: String) {
        self.name = name
    }
}

// MARK:- MeteorDocument
public final class MeteorDocument : MeteorResponse {
    
    public let id: String, fields: MeteorKeyValue?, cleared: [String]?
    
    init(name: String, id: String, fields: MeteorKeyValue?, cleared: [String]?) {
        self.id = id
        self.fields = fields
        self.cleared = cleared
        super.init(name)
    }
}


// MARK:- MeteorMethod
public final class MeteorMethod : MeteorResponse {
    
    public let result: Any?, error: MeteorError?
        
    init(name: String, result: Any?, error: MeteorError?) {
        self.result = result
        self.error = error
        super.init(name)
    }
}


fileprivate extension MeteorClient {
    
    /// Make NSNotification against given ddp event
    /// - Parameters:
    ///   - name: string
    ///   - event: MeteorEvents
    /// - Returns: NSNotification.Name
    func makeNotificationName(_ name: String, event: MeteorEvents) -> NSNotification.Name {
        let identifier = METEOR_DDP + name + event.rawValue
        return NSNotification.Name(rawValue: identifier)
    }
}

internal extension MeteorClient {
    
    /// Broadcast event
    /// - Parameters:
    ///   - name: name string
    ///   - event: MeteorEvents
    ///   - value: MeteorResponse
    func broadcastEvent(_ name: String, event: MeteorEvents, value: MeteorResponse) {
        DispatchQueue.main.async {
            self.delegate?.didReceive(name: event, event: value)
        }
        
        let identifier = makeNotificationName(name, event: event)
        notificationCenter.post(name: identifier, object: value, userInfo: nil)
        // TODO:- Make sure multiple in queue
    }
}

public extension MeteorClient {
    
    /// Add Observer on event
    /// - Parameters:
    ///   - name: name
    ///   - event: event
    ///   - callback: callback
     func addEventObserver(_ name: String, event: MeteorEvents, callback: ((MeteorResponse) -> ())?) {
        let identifier = makeNotificationName(name, event: event)
        
        notificationCenter.addObserver(forName: identifier, object: nil, queue: .main) {
            guard let response = $0.object as? MeteorResponse else {
                logger.logError(.receiveMessage, "Failed to parse notification payload")
                return
            }
            callback?(response)
        }
    }
    
    /// Remove Observer on events
    /// - Parameters:
    ///   - name: name
    ///   - event: event array
    func removeEventObservers(_ name: String, event: [MeteorEvents]) {
        event.forEach {
            let identifier = makeNotificationName(name, event: $0)
            notificationCenter.removeObserver(self, name: identifier, object: nil)
        }
    }
    
}
