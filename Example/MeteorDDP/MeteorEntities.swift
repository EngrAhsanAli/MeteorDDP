//
//  MeteorEntities.swift
//  MeteorDDP_Example
//
//  Created by Muhammad Ahsan Ali on 2020/02/28.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import MeteorDDP

// MARK: - TaskModel
struct TaskModel: Codable {
    let createdAt: CreatedAt?
    let owner, id, text: String
    let username: String?

    enum CodingKeys: String, CodingKey {
        case createdAt, owner, username
        case id = "_id"
        case text
    }
    
    // MARK: - CreatedAt
    struct CreatedAt: Codable {
        let date: Int

        enum CodingKeys: String, CodingKey {
            case date = "$date"
        }
    }
}


