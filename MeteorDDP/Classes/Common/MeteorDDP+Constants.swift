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

import XCGLogger

// MARK:- Globals

let callbackDispatchTime = DispatchTime.distantFuture

let logger = XCGLogger(identifier: "MeteorDDP")

public typealias MeteorMethodCallback = (_ result:Any?, _ error:MeteorError?) -> ()
public typealias MeteorConnectedCallback = (_ session:String) -> ()
public typealias MeteorCallback = () -> ()

// MARK:- MeteorUser
enum MeteorUser: String  {
    case DDP_ID, DDP_EMAIL, DDP_USERNAME, DDP_TOKEN, DDP_TOKEN_EXPIRES, DDP_LOGGED_IN
}

// MARK:- MeteorNotificationType
public enum MeteorNotificationType: String  {
    case userDidLogin,userDidLogout, socketDidClose, socketError, socketDidDisconnected, socketFailed, collectionDidChange
}

// MARK:- MeteorMessageType
public enum MeteorMessageType: String {
    
    case connected, failed, ping, pong, nosub
    case added, changed, removed
    case ready, addedBefore, movedBefore, result
    case updated, error, unhandled
    
}

// MARK:- MeteorLoginType
public enum MeteorLoginType: String {
    case twitter, github, google, facebook
}

// MARK:- MeteorResponse
public struct MeteorResponse {
    public var result:Any?
    public var error:MeteorError?
}
