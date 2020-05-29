//
//  MeteorOAuth.swift
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

// MARK:- 🚀 MeteorLoginService - provide login through thrid-party services
public enum MeteorLoginService: String {
    case twitter, github, google, facebook
}

// MARK:- 🚀 MeteorOAuth - support login through thrid-party services
public class MeteorOAuth {
    
    var url: String
    
    var httpUrl: String {
        url.httpUrl
    }

    init(_ url: String) {
        self.url = url
    }
    
    func stateParam(credentialToken: String, redirectUrl: String) -> String {
        return "{\"redirectUrl\":\"\(redirectUrl)\",\"loginStyle\":\"redirect\",\"isCordova\":\"false\",\"credentialToken\":\"\(credentialToken)\"}".toBase64
    }
    
    func twitter() -> String {
        
        let token = String.randomBase64()
        let redirect = "\(httpUrl)/_oauth/twitter"
        let state = stateParam(credentialToken: token, redirectUrl: redirect)
        
        return "\(httpUrl)/_oauth/twitter/?requestTokenAndRedirect=true&state=\(state)"
    
    }
    
    func facebook(appId: String) -> String {
        
        let token = String.randomBase64()
        let redirect = "\(httpUrl)/_oauth/facebook"
        let state = stateParam(credentialToken: token, redirectUrl: redirect)
        
        let scope = "email"
        
        var url = "https://m.facebook.com/v2.2/dialog/oauth?client_id=\(appId)"
        url += "&redirect_uri=\(redirect)"
        url += "&scope=\(scope)"
        url += "&state=\(state)"
        
        return url
      
    }
    
    func github(clientId: String) -> String {
        
        let token = String.randomBase64()
        let redirect = "\(httpUrl)/_oauth/github"
        let state = stateParam(credentialToken: token, redirectUrl: redirect)
        
        let scope = "user:email"
        
        var url = "https://github.com/login/oauth/authorize?client_id=\(clientId)"
        url += "&redirect_uri=\(redirect)"
        url += "&scope=\(scope)"
        url += "&state=\(state)"
        
        return url
    }
    
    func google(clientId: String) -> String {
        
        let token = String.randomBase64()
        let redirect = "\(httpUrl)/_oauth/google"
        let state = stateParam(credentialToken: token, redirectUrl: redirect)

        let scope = "email"
        
        var url = "https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=\(clientId)"
        url += "&redirect_uri=\(redirect)"
        url += "&scope=\(scope)"
        url += "&state=\(state)"
        
        return url
    }
    
    
    public func getServiceUrl(_ service: MeteorLoginService, clientId: String) -> String {
        var url: String
        
        switch service {
            
        case .twitter:
            url = twitter()
        case .facebook:
            url = facebook(appId: clientId)
        case .github:
            url = github(clientId: clientId)
        case .google:
            url = google(clientId: clientId)
        }
        
        return url
    }
    

}
