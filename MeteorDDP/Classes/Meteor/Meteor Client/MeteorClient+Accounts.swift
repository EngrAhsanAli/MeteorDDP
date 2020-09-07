//
//  MeteorClient+Accounts.swift
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


// MARK:- 🚀 Meteor Accounts - API for handling user login and registration
// More - https://docs.meteor.com/api/accounts.html
public extension MeteorClient {
    
    /// Logs a user into the server using an email/username and password
    /// - Parameters:
    ///   - id: An email or username string
    ///   - password: A password string
    ///   - callback: A closure with result and error parameters describing the outcome of the operation
    func login(_ id: String, password: String, callback: MeteorMethodCallback?) {
        if id.isValidEmail {
            loginWithPassword(id, password: password, callback: callback)
        }
        else {
            loginWithUsername(id, password: password, callback: callback)
        }
    }
    
    /// Invokes a Meteor method to create a user account with a given username, email and password, and a NSDictionary containing a user profile
    /// - Parameters:
    ///   - email: email address string (Must be valid email )
    ///   - username: username string
    ///   - password: password string
    ///   - profile: Profile dictionary
    ///   - callback: callback
    func signup(_ email: String?, username: String?, password: String, profile: MeteorKeyValue?, callback: MeteorMethodCallback?) {
        var id: UserMessage?
        if let email = email, email.isValidEmail {
            id = .email(email)
        }
        if let username = username {
            id = .username(username)
        }
        
        if let id = id {
            var msg: [UserMessage] = [id, .password(password)]
            if let profile = profile {
                msg.append(.profile(profile))
            }
            loginUser(params: makeMessage(msg), method: .createUser, callback: callback)
        }
        else {
            logger.logError(.signup, "Email and Username both shouldn't empty")
        }
    }
    
    /// Logs a user into the server using an email and password
    /// - Parameters:
    ///   - email: An email string
    ///   - password: A password string
    ///   - callback: A closure with result and error parameters describing the outcome of the operation
    func loginWithPassword(_ email: String, password: String, callback: MeteorMethodCallback?) {
        if !(loginWithToken(callback)) {
            
            let msg: [UserMessage] = [.email(email), .password(password)]
            loginUser(params: makeMessage(msg), method: .login, callback: callback)
        }
    }
    
    /// Logs a user into the server using a username and password
    /// - Parameters:
    ///   - username: A username string
    ///   - password: A password string
    ///   - callback: A closure with result and error parameters describing the outcome of the operation
    func loginWithUsername(_ username: String, password: String, callback: MeteorMethodCallback?) {
        if !(loginWithToken(callback)) {
            let msg: [UserMessage] = [.username(username), .password(password)]
            loginUser(params: makeMessage(msg), method: .login, callback: callback)

        }
    }
    
    /// Logs a user out and removes their account data from NSUserDefaults. When it completes, it posts a notification: DDP_USER_DID_LOGOUT on the main queue
    /// - Parameter callback: A closure with result and error parameters describing the outcome of the operation
    func logout(_ callback: MeteorMethodCallback? = nil) {
        call(Method.logout.rawValue, params: nil) { result, error in
            if let error = error {
                error.log()
            } else {
                self.userMainQueue.addOperation() {
                    self.resetUserData()
                }
            }
            callback?(result, error)
        }
    }
    
    /// Login with oAuth
    /// - Parameters:
    ///   - service: MeteorLoginService
    ///   - clientId: String
    ///   - viewController: UIViewController
    func login<T: UIViewController>(with service: MeteorLoginService, clientId: String, viewController: T) {
        if !loginWithToken(nil) {
            let oauthDialog = MeteorOAuthViewController()
            oauthDialog.serviceName = service.rawValue.capitalized
            let oauth = MeteorOAuth(socket.url.absoluteString)
            oauthDialog.url = URL(string: oauth.getServiceUrl(service, clientId: clientId))
            viewController.present(oauthDialog, animated: true, completion: nil)
        } else {
            logger.log(.login, "Already have valid server login credentials. Logging in with preexisting login token", .normal)
        }
    }
    
}


// MARK:- 🚀 Meteor Client -
internal extension MeteorClient {
    
    /// Login User with params
    /// - Parameters:
    ///   - params: MeteorKeyValue
    ///   - method: login, logout or register
    ///   - callback: callback
    func loginUser(params: MeteorKeyValue, method: Method, callback: MeteorMethodCallback?) {        
        call(method.rawValue, params: [params]) { result, error in
            
            if let error = error {
                error.log()
            }
            else {
                self.saveLoggedInUser(result, error: error)
            }
            
            self.userMainQueue.addOperation() {
                callback?(result, error)
            }
            
        }
    }
    
    /// Attempts to login a user with a token, if one exists
    /// - Parameter callback: A closure with result and error parameters describing the outcome of the operation
    @discardableResult
    func loginWithToken(_ callback: MeteorMethodCallback?) -> Bool {
        if let user = self.getPersistedUser {
            self.loggedInUser = user
            if (user.tokenExpires.compare(Date()) == ComparisonResult.orderedDescending) {
                let params = ["resume": user.token]
                loginUser(params: params, method: .login, callback: callback)
                return true
            }
        }
        return false
    }
    
    /// Persist loggedIn User
    /// - Parameters:
    ///   - result: Response
    ///   - error: Error
    func saveLoggedInUser(_ result: Any?, error: MeteorError?) {
        
        if  let data = result as? MeteorKeyValue,
            let id = data["id"] as? String,
            let token = data["token"] as? String,
            let tokenExpires = data["tokenExpires"] as? MeteorKeyValue {
            
            self.loggedInUser = UserHolder(id: id, token: token, tokenExpires: tokenExpires.dateFromTimestamp)
            
            self.persistUser(object: self.loggedInUser!)
        }
        else if let error = error {
            error.log()
        }

    }
    
    /// Reset LoggedIn User Data
    func resetUserData() {
        self.loggedInUser = nil
        UserDefaults.standard.removeObject(forKey: METEOR_DDP)
        UserDefaults.standard.synchronize()
    }
}
