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

import Foundation
import UIKit


extension Meteor {
    internal static func loginWithService<T: UIViewController>(_ service: MeteorLoginType, clientId: String, viewController: T) {
        if Meteor.client.loginWithToken(nil) == false {
            var url:String!
            
            switch service {
            case .twitter:
                url = MeteorOAuth.twitter()
            case .facebook:
                url =  MeteorOAuth.facebook(appId: clientId)
            case .github:
                url = MeteorOAuth.github(clientId: clientId)
            case .google:
                url = MeteorOAuth.google(clientId: clientId)
            }
            
            let oauthDialog = MeteorOAuthViewController()
            oauthDialog.serviceName = service.rawValue.capitalized
            oauthDialog.url = NSURL(string: url)
            viewController.present(oauthDialog, animated: true, completion: nil)
        } else {
            logger.debug("Already have valid server login credentials. Logging in with preexisting login token")
        }
    }
    
    /**
     Logs a user into the server using Twitter
     
     - parameter viewController:    A view controller from which to launch the OAuth modal dialog
     */
    
    public static func loginWithTwitter<T: UIViewController>(_ viewController: T) {
        Meteor.loginWithService(.twitter, clientId: "", viewController: viewController)
    }
    
    /**
     Logs a user into the server using Facebook
     
     - parameter viewController:    A view controller from which to launch the OAuth modal dialog
     - parameter clientId:          The apps client id, provided by the service (Facebook, Google, etc.)
     */
    
    public static func loginWithFacebook<T: UIViewController>(_ clientId: String, viewController: T) {
        Meteor.loginWithService(.facebook, clientId: clientId, viewController: viewController)
    }
    
    /**
     Logs a user into the server using Github
     
     - parameter viewController:    A view controller from which to launch the OAuth modal dialog
     - parameter clientId:          The apps client id, provided by the service (Facebook, Google, etc.)
     */
    
    public static func loginWithGithub<T: UIViewController>(_ clientId: String, viewController: T) {
        Meteor.loginWithService(.github, clientId: clientId, viewController: viewController)
    }
    
    /**
     Logs a user into the server using Google
     
     - parameter viewController:    A view controller from which to launch the OAuth modal dialog
     - parameter clientId:          The apps client id, provided by the service (Facebook, Google, etc.)
     */
    
    public static func loginWithGoogle<T: UIViewController>(_ clientId: String, viewController: T) {
        Meteor.loginWithService(.google, clientId: clientId, viewController: viewController)
    }
    
}
