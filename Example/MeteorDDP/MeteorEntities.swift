//
//  MeteorEntities.swift
//  MeteorDDP_Example
//
//  Created by Muhammad Ahsan Ali on 2020/02/28.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import MeteorDDP

class Document: MeteorDocument {
    
    var state:String?
    var city:String?
    
}

class TestModel:MeteorDocument {
    var msg: String?
    var optional: String?
}
