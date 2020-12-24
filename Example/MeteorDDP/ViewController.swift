//
//  ViewController.swift
//  MeteorDDP
//
//  Created by engrahsanali on 06/02/2020.
//  Copyright (c) 2020 engrahsanali. All rights reserved.
//

import UIKit
import MeteorDDP

class ViewController: UIViewController {
    
    @IBOutlet weak var loggerTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MeteorLogger.loggingLevel = .normal
        meteor.delegate = self
        
        clearLogAction(self)
        connectAction(self)
    }
    
    @IBAction func checkAttrsAction(_ sender: Any) {
        self.logResult("Logged In? " + (meteor.isLoggedIn ? "Yep" : "Nope"))
        self.logResult("Found User ID? " + (meteor.userId != nil ? "Yep" : "Nope"))
        
        meteor.call(callName, params: nil) { (res, err) in
            print("Call Result ", res)
        }

        meteorCollection.subscribe(collection, params: nil) { events, document in
            print("Subscription to collection " + collection)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                meteorCollection.unsubscribe(collection)
            }
        }

        meteorCollection.collectionDidChange = { collection, id in
            collection.documents.forEach { (d) in
                self.logTasks(d, nil)
            }
        }
        
    }
    
    @IBAction func connectAction(_ sender: Any) {
        meteor.connect {
            self.logResult("Session: " + $0)
//            self.loginWithUsernameAction(self)
        }
    }
    
    @IBAction func loginWtihEmailAction(_ sender: Any) {
        meteor.loginWithPassword(user, password: pass) { (result, error) in
            if error != nil {
                self.logResult("Login Failed")
            }
            else {
                self.logResult("Successfully loggedIn")
            }
        }
    }
    
    @IBAction func loginWithUsernameAction(_ sender: Any) {
        meteor.loginWithUsername(user, password: pass) { (result, error) in
            if error != nil {
                self.logResult("Login Failed")
            }
            else {
                self.logResult("Successfully loggedIn")
            }
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        meteor.logout { (_, _) in
            self.logResult("Successfully logout")
        }
    }
    
    @IBAction func disconnectAction(_ sender: Any) {
        meteor.disconnect()
        self.logResult("Disconnected")
    }
    
    @IBAction func clearLogAction(_ sender: Any) {
        loggerTextView.text = ""
    }
    
}

extension ViewController {
    
    func logResult(_ logString: String) {
        DispatchQueue.main.async {
            self.loggerTextView.text += "\n\n \(logString)"
            self.loggerTextView.scrollToBottom()
        }
    }
    
    func logTasks(_ res: Any?, _ err: MeteorError?) {
        if let response = res as? [MeteorKeyValue] {
            self.logTask(response)
        }
        else if let response = res as? MeteorKeyValue {
            self.logTask([response])
        }
        else {
            if let err = err {
                self.logResult("Meteor error: " + err.localizedDescription)
            }
        }
    }
    
    func logTask(_ res: Any) {
        if let response = res as? [MeteorKeyValue] {
            response.forEach {
                if let task = MeteorEncodable.decode(TaskModel.self, from: $0) {
                    self.logResult("Task: " + task.text)
                }
            }
        }
        
    }
    
}

extension ViewController: MeteorDelegate {
    
    func didReceive(name: MeteorEvents, event: Any) {
        switch name {
            
        case .method:
            self.logResult("Method Name " + (event as? MeteorMethod)!.name)
            
        case .websocket:
            if let event = (event as? WebSocketEvent) {
                switch event {
                case .connected:
                    self.logResult("Webscoket Connected ")
                case .disconnected:
                    self.logResult("Webscoket Disconnected ")
                case .text(_):
                    self.logResult("Webscoket Message Received ")
                case .error(let err):
                    if let noInternet = err?.noInternet, noInternet == true {
                        self.logResult("No Internet Connection ")
                    }
                    else {
                        self.logResult("Webscoket Error ")
                    }
                }
            }
            
        case .dataAdded:
            self.logResult("Added data in collection " + (event as? MeteorDocument)!.name)
            
        case .dataChange:
            self.logResult("Changed data in collection " + (event as? MeteorDocument)!.name)
            
        case .dataRemove:
            self.logResult("Removed data in collection " + (event as? MeteorDocument)!.name)
            
        }
    }
    
    
}
