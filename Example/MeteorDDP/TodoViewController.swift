//
//  TodoViewController.swift
//  MeteorDDP_Example
//
//  Created by Muhammad Ahsan Ali on 2020/04/16.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import MeteorDDP

class TodoViewController: UIViewController {

    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var documents = [String: MeteorKeyValue]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        inputField.isEnabled = meteor.isLoggedIn
        
        if inputField.isEnabled {
            
            sub()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.documents.removeAll()
                self.tableView.reloadData()
                self.sub()
            }
            
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.delegate = nil
        tableView.dataSource = nil
        meteor.unsubscribe(withName: collection, allowRemove: false, callback: {
            meteor.removeEventObservers(collection, event: [.dataAdded]) // no need
            self.documents.removeAll()
        })
        
    }
    

    func sub() {
        meteor.unsubscribe(withName: collection, allowRemove: false, callback: {
            
            meteor.subscribe(collection, params:  nil, collectionName: "tasks", callback: { (event, doc) in
                print("Event received in closure ", event)
                print("Document received in closure ", doc)
                
                switch event {
                
                case .dataAdded:
                    
                    self.documents[doc.id] = doc.fields
                    self.tableView.reloadData()
                    
                    
                    
                    break
                    
                case .dataRemove:

                    break
                    
                default:
                    break
                    
                }
                
            }) {
                print("Subscription Done")
            }
            
        })
    }
}

extension TodoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TaskCell
        let document = Array(documents.values)[indexPath.row]

        cell.name.text = document["text"] as? String
        cell.updateButton.tag = indexPath.row
        cell.deleteButton.tag = indexPath.row

        cell.updateButton.addTarget(self, action: #selector(updateTask(sender:)), for: .touchUpInside)
        cell.deleteButton.addTarget(self, action: #selector(deleteTask(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func updateTask(sender: UIButton){
        
        let documentId = Array(documents.keys)[sender.tag]
        
        var keyValue = MeteorKeyValue()
        if let text = documents[documentId]?["text"] as? String {
            keyValue["text"] = text + " - Modified at " + Date().description
        }
        
        meteor.updateColection(collection, type: .update, documents: [["_id":documentId],["$set": keyValue]]) { (res, error) in
            if error == nil {
                self.documents[documentId]?["text"] = keyValue["text"]
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func deleteTask(sender: UIButton) {
        let documentId = Array(documents.keys)[sender.tag]
        
        meteor.updateColection(collection, type: .remove, documents: [["_id": documentId]]) { (res, error) in
            if error == nil {
                self.documents[documentId] = nil
                self.tableView.reloadData()
            }
        }
    }
    
}


extension TodoViewController: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        meteor.call("tasks.insert", params: [textField.text!]) { (res, error) in
            if error == nil {
                textField.text = nil
            }
        }
        
        return true
    }
    
    
}
