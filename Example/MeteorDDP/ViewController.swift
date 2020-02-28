//
//  ViewController.swift
//  MeteorDDP
//
//  Created by engrahsanali on 02/26/2020.
//  Copyright (c) 2020 engrahsanali. All rights reserved.
//

import UIKit
import MeteorDDP

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Meteor.connect(url) {
            // do something after the client connects
        }
    }
    
    
}
