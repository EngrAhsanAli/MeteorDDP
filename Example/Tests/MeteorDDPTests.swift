//
//  MeteorDDPTests.swift
//  MeteorDDP_Tests
//
//  Created by Muhammad Ahsan Ali on 2020/02/28.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import MeteorDDP

class MeteorTest: QuickSpec {
    
    override func spec() {
        
        let client = Meteor.client
        let collection = MeteorCollection<Document>(name: "test-collection")
        
        describe("Document methods send notifications") {
            
            it("sends a message when a document is added") {
                
                try! client.messageHandler(added[0])
                
                expect(collection.documents["2gAMzqvE8K8kBWK8F"]).toEventuallyNot(beNil())
                expect(collection.documents["2gAMzqvE8K8kBWK8F"]?.city).toEventually(equal("Boston"))
            }
            
            it("sends a message when a document is removed") {
                
                try! client.messageHandler(added[1])
                expect(collection.documents["ByuwhKPGuLru8h4TT"]).toEventuallyNot(beNil())
                expect(collection.documents["ByuwhKPGuLru8h4TT"]!.city).toEventually(equal("Truro"))
                
                try! client.messageHandler(removed[1])
                expect(collection.documents["ByuwhKPGuLru8h4TT"]).toEventually(beNil())
            }
            
        
            it("sends a message when a document is updated") {
                
                try! client.messageHandler(added[2])
                expect(collection.documents["AGX6vyxCJtjqdxbFH"]).toEventuallyNot(beNil())
                expect(collection.documents["AGX6vyxCJtjqdxbFH"]!.city).toEventually(equal("Austin"))
                
                try! client.messageHandler(changed[2])
                expect(collection.documents["AGX6vyxCJtjqdxbFH"]!.city).toEventually(equal("Houston"))

            }
        
        }
        
        describe ("MeteorDDPMessage") {
            
            it ("can be created from a Dictionary") {
                let message = MeteorMessage(message: ["msg":"test", "id":"test100"])
                expect(message.hasProperty("msg")).to(beTrue())
                expect(message.hasProperty("id")).to(beTruthy())
                expect(message.id!).to(equal("test100"))
                expect(message.message!).to(equal("test"))
            }
            
            it ("can be created from a String") {
                let message = MeteorMessage(message: "{\"msg\":\"test\", \"id\":\"test100\"}")
                expect(message.hasProperty("msg")).to(beTruthy())
                expect(message.hasProperty("id")).to(beTruthy())
                expect(message.id!).to(equal("test100"))
                expect(message.message!).to(equal("test"))
            }
            
            
            it ("handles malformed json without crashing") {
                let message = MeteorMessage(message: "{\"msg\":\"test\", \"id\"test100\"}")
                expect(message.isError).to(beTrue())
                expect(message.reason!).to(equal("MeteorDDP JSON serialization error."))
            }
            
            it ("Sends malformed json to the error handler callback") {
                
                var error:MeteorError!
                
                let client = MeteorClient()
                client.events.onError = {e in error = e }
                let message = MeteorMessage(message: "{\"msg\":\"test\", \"id\"test100\"}")
                try! client.messageHandler(message)
                
                expect(message.isError).to(beTrue())
                expect(message.reason!).to(equal("MeteorDDP JSON serialization error."))
                
                expect(error).toEventuallyNot(beNil())
                expect(error.isValid).toEventually(beTrue())
                expect(error.reason!).to(equal("MeteorDDP JSON serialization error."))
            }
            
        }
        
        describe ("MeteorDDPMessageHandler routing") {
            
            it ("can handle an 'added' message"){
                let client = MeteorClient()
                client.events.onAdded = {collection, id, fields in
                    expect(collection).to(equal("test-collection"))
                    expect(id).to(equal("2gAMzqvE8K8kBWK8F"))
                    let city = fields!["city"]! as! String
                    expect(city).to(equal("Boston"))
                }
                try! client.messageHandler(added[0])
            }
            
            it ("can handle a 'removed' message") {
                let client = MeteorClient()
                client.events.onRemoved = {collection, id in
                    expect(collection).to(equal("test-collection"))
                    expect(id).to(equal("2gAMzqvE8K8kBWK8F"))
                }
                try! client.messageHandler(removed[0])
            }

        }
        
        it ("Handle null values in the Dictionary, while parsing as a MeteorDocument") {
            let collection = MeteorCollection<TestModel>(name: "testCollection")
            
            let message = MeteorMessage(message: "{\"id\":\"testId\", \"msg\":\"test message\", \"optional\":<null>}")
            
            collection.documentWasAdded("testCollection", id: message.id!, fields: message.fields)
            
            print("Message added into the collection: \(collection)")
        }
        
    }
    
}

