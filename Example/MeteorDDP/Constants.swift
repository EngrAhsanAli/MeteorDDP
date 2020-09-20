//
//  Constants.swift
//  MeteorDDP_Tests
//
//  Created by Muhammad Ahsan Ali on 2020/02/28.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import MeteorDDP

let meteor: MeteorClient = {
    MeteorClient(url: url)
}()

let meteorCollection: MeteorCollections = {
    MeteorCollections(client: meteor)
}()

let url = "ws://54.150.237.15:4000//websocket"
let user = "mike@goflow.com"
let pass = "aaaaaa"
let collection = "subscribeAllGroupsOptV2"
let callName = "getAllGroupsPaginated"


extension UITextView {
    func scrollToBottom() {
        let textCount: Int = text.count
        guard textCount >= 1 else { return }
        scrollRangeToVisible(NSMakeRange(textCount - 1, 1))
    }
}
