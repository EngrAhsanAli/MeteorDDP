//
//  MeteorClient+User.swift
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

// MARK:- 🚀 MeteorClient+Accounts -
internal extension MeteorClient {
    
    /// Persisit User
    /// - Parameter object: LoggedIn User Object
    func persistUser(object: UserHolder) {
        if let data = try? MeteorEncodable.encode(object) {
            UserDefaults.standard.set(data, forKey: METEOR_DDP)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// Persisted User
    var getPersistedUser: UserHolder? {
        if let data = UserDefaults.standard.value(forKey: METEOR_DDP) {
            return MeteorEncodable.decode(UserHolder.self, from: data)
        }
        return nil
    }

}

// MARK:- 🚀 Meteor Client -
public extension MeteorClient {

    /// Check for current loggedIn user
    var isLoggedIn: Bool { getPersistedUser != nil }
    
    /// Returns the client userId, if it exists
    var userId: String? { loggedInUser?.id }
}
