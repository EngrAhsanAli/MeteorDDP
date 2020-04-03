//
//  Constants.swift
//  MeteorDDP_Tests
//
//  Created by Muhammad Ahsan Ali on 2020/02/28.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import MeteorDDP


//  *** methods that are tested against a server are tested against the url below ***
//let url = "ws://MeteorDDP.meteor.com/websocket"

//let url = "ws://52.199.85.68:3000/websocket"
let url = "ws://localhost:3000/websocket"
let user = "mjgaylord@gmail.com"
let pass = "mjgaylord123"

let ready = MeteorMessage(message: "{\"msg\":\"ready\", \"subs\":[\"AllStates\"]}")
let nosub = MeteorMessage(message: ["msg":"nosub", "id":"AllStates"])

let added = [MeteorMessage(message: "{\"collection\" : \"test-collection\", \"id\" : \"2gAMzqvE8K8kBWK8F\", \"fields\" : {\"state\" : \"MA\", \"city\" : \"Boston\"}, \"msg\" : \"added\"}"),
    MeteorMessage(message:"{\"collection\" : \"test-collection\", \"id\" : \"ByuwhKPGuLru8h4TT\", \"fields\" : {\"state\" : \"MA\", \"city\" : \"Truro\"}, \"msg\" : \"added\"}"),
    MeteorMessage(message:"{\"collection\" : \"test-collection\", \"id\" : \"AGX6vyxCJtjqdxbFH\", \"fields\" : {\"state\" : \"TX\", \"city\" : \"Austin\"}, \"msg\" : \"added\"}")]

let removed = [MeteorMessage(message: ["msg" : "removed", "id" : "2gAMzqvE8K8kBWK8F","collection" : "test-collection"]),
    MeteorMessage(message: ["msg" : "removed", "id" : "ByuwhKPGuLru8h4TT", "collection" : "test-collection"]),
    MeteorMessage(message:["msg" : "removed", "id" : "AGX6vyxCJtjqdxbFH", "collection" : "test-collection"])]

let changed = [MeteorMessage(message: "{\"collection\" : \"test-collection\", \"id\" : \"2gAMzqvE8K8kBWK8F\",\"cleared\" : [\"city\"], \"fields\" : {\"state\" : \"MA\", \"city\" : \"Amherst\"}, \"msg\" : \"changed\"}"),
    MeteorMessage(message:"{\"collection\" : \"test-collection\", \"id\" : \"ByuwhKPGuLru8h4TT\", \"fields\" : {\"state\" : \"MA\", \"city\" : \"Cambridge\"}, \"msg\" : \"changed\"}"),
    MeteorMessage(message:"{\"collection\" : \"test-collection\", \"id\" : \"AGX6vyxCJtjqdxbFH\", \"fields\" : {\"state\" : \"TX\", \"city\" : \"Houston\"}, \"msg\" : \"changed\"}")]

let userAddedWithPassword = MeteorMessage(message: "{\"collection\" : \"users\", \"id\" : \"123456abcdefg\", \"fields\" : {\"roles\" : [\"admin\"], \"emails\" : [{\"address\" : \"test@user.com\", \"verified\" : false}], \"username\" : \"test\"}, \"msg\" : \"added\"}")



let addedRealm = [MeteorMessage(message: "{\"collection\" : \"Cities\", \"id\" : \"2gAMzqvE8K8kBWK8F\", \"fields\" : {\"state\" : \"MA\", \"city\" : \"Boston\"}, \"msg\" : \"added\"}"),
    MeteorMessage(message:"{\"collection\" : \"Cities\", \"id\" : \"ByuwhKPGuLru8h4TT\", \"fields\" : {\"state\" : \"MA\", \"city\" : \"Truro\"}, \"msg\" : \"added\"}"),
    MeteorMessage(message:"{\"collection\" : \"Cities\", \"id\" : \"AGX6vyxCJtjqdxbFH\", \"fields\" : {\"state\" : \"TX\", \"city\" : \"Austin\"}, \"msg\" : \"added\"}")]

let removedRealm = [MeteorMessage(message: ["msg" : "removed", "id" : "2gAMzqvE8K8kBWK8F","collection" : "Cities"]),
    MeteorMessage(message: ["msg" : "removed", "id" : "ByuwhKPGuLru8h4TT", "collection" : "Cities"]),
    MeteorMessage(message:["msg" : "removed", "id" : "AGX6vyxCJtjqdxbFH", "collection" : "Cities"])]


let changedRealm = [MeteorMessage(message: "{\"collection\" : \"Cities\", \"id\" : \"2gAMzqvE8K8kBWK8F\",\"cleared\" : [\"city\"], \"fields\" : {\"state\" : \"MA\", \"city\" : \"Amherst\"}, \"msg\" : \"changed\"}"),
    MeteorMessage(message:"{\"collection\" : \"Cities\", \"id\" : \"ByuwhKPGuLru8h4TT\", \"fields\" : {\"state\" : \"MA\", \"city\" : \"Cambridge\"}, \"msg\" : \"changed\"}"),
    MeteorMessage(message:"{\"collection\" : \"Cities\", \"id\" : \"AGX6vyxCJtjqdxbFH\", \"fields\" : {\"state\" : \"TX\", \"city\" : \"Houston\"}, \"msg\" : \"changed\"}")]


