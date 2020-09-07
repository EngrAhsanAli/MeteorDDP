//
//  MeteorOAuthViewController.swift
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

import WebKit

// MARK:- 🚀 MeteorOAuth -
// TODO: Handle login failure > specific actions for cancellation, for example
// TODO: Gotchas: connecting over wss, but registered domain is http...
// TODO: Activity indicator?
// TODO: Add redirect not popup; register as web app when setting up services to instructions
// TODO: Login first with stored token
// TODO: Tests
// MARK:- 🚀 MeteorOAuth - View Controller to login meteor from third-party services
public class MeteorOAuthViewController: UIViewController {
    
    // App must be set to redirect, rather than popup
    // https://github.com/meteor/meteor/wiki/OAuth-for-mobile-Meteor-clients#popup-versus-redirect-flow
    
    var meteor: MeteorClient?
    
    public var navigationBar: UINavigationBar!
    public var cancelButton: UIBarButtonItem!
    public var webView: WKWebView!
    public var url: URL!
    public var serviceName: String?
    
    override public func viewDidLoad() {
        
        navigationBar = UINavigationBar() // Offset by 20 pixels vertically to take the status bar into account
        let navigationItem = UINavigationItem()
        
        navigationItem.title = "Login"

        if let name = serviceName {
            navigationItem.title = "Login with \(name)"
        }
        
        cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = cancelButton
        navigationBar!.items = [navigationItem]
                
        // Configure WebView
        let request = URLRequest(url: url)
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.load(request)
        
        self.view.addSubview(webView)
        self.view.addSubview(navigationBar)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 64)
        webView.frame = CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height - 64)
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func signIn(token: String, secret: String) {
        let params = ["oauth":["credentialToken": token, "credentialSecret": secret]] as MeteorKeyValue
        meteor?.loginUser(params: params, method: .login) { result, error in
            logger.log(.login, "Meteor login attempt \(String(describing: result)), \(String(describing: error))", .normal)
            self.close()
        }
    }
    
    
}


// MARK:- WKNavigationDelegate Methods
extension MeteorOAuthViewController: WKNavigationDelegate {
    
    /* Start the network activity indicator when the web view is loading */
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    /* Stop the network activity indicator when the loading finishes */
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false        
        webView.evaluateJavaScript("JSON.parse(document.getElementById('config').innerHTML)") { (html, error) in
            if let json = html as? MeteorKeyValue {
                if let secret = json["credentialSecret"] as? String,
                    let token = json["credentialToken"] as? String {
                    webView.stopLoading()
                    self.signIn(token: token, secret: secret)
                }
            }
            else {
                logger.logError(.error, "There was no json here")
            }
        }
    }
    
}
