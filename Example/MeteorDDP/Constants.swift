//
//  Constants.swift
//  MeteorDDP_Tests
//
//  Created by Muhammad Ahsan Ali on 2020/02/28.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import MeteorDDP

let meteor: MeteorClient = {
    MeteorClient(url: url, webSocket: .webSocketTask)
}()

let meteorCollection: MeteorCollections = {
    MeteorCollections(client: meteor)
}()

let url = "ws://localhost:3000/websocket"
let user = "meteorddp"
let pass = "123456"
let collection = "tasks"
let callName = "tasks.getAll"


extension UITextView {
    func scrollToBottom() {
        let textCount: Int = text.count
        guard textCount >= 1 else { return }
        scrollRangeToVisible(NSMakeRange(textCount - 1, 1))
    }
}
