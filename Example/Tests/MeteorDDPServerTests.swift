//
//  MeteorDDPServerTests.swift
//  MeteorDDP_Tests
//
//  Created by Muhammad Ahsan Ali on 2020/02/28.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import MeteorDDP


// Tests against a Meteor instance at MeteorDDP.meteor.com
class MeteorDDPServerTests:QuickSpec {
    override func spec() {
        
        describe ("MeteorDDP Connection") {
            
            it ("can connect to a DDP server"){
                var testSession:String?
                let client = MeteorClient()
                client.connect(url) { session in testSession = session }
                expect(client.connection.ddp).toEventually(beTrue(), timeout:5)
                expect(client.connection.session).toEventually(equal(testSession), timeout:5)
            }
        }
        
        // DDP Methods
        // tests login:, logout:, insert:, remove:, update:
        describe ("MeteorDDP Methods") {
            
            it ("can login to a Meteor server") {
                
                // On connect, the client should set the client.connection.session property
                // After logging in with a username and password, the client should receive a result
                // object that the session token
                
                var testResult:NSDictionary!
                var testSession:String!
                
                let client = MeteorClient()
                client.connect(url) { session in
                    testSession = session
                    client.loginWithPassword(user, password: pass) { result, e in
                        testResult = result! as? NSDictionary
                    }
                }
                
                // Both of these should be non nil; the callbacks should assign them their respective values
                expect(testResult).toEventuallyNot(beNil(), timeout:5)
                expect(testSession).toEventuallyNot(beNil(), timeout:5)
                
                let userDefaultsToken = client.userData.object(forKey: "MeteorDDP_TOKEN") as! String
                let resultToken = testResult["token"] as! String
                
                expect(userDefaultsToken).toEventually(equal(resultToken), timeout:5)
                expect(testSession).toEventually(equal(client.connection.session), timeout:5)
            }
            
            it ("can add and remove a document on the server"){
                var added = [NSDictionary]()
                var removed = [String]()
                let client = MeteorClient()
                let _id = client.getId()
                
                client.events.onAdded = { collection, id, fields in if ((collection == "test-collection2") && (_id == id)) { added.append(fields!) } }
                client.events.onRemoved = { collection, id in removed.append(id) }
                
                client.connect(url) { session in
                    print("Connected to DDP server!!! \(session)")
                    client.loginWithPassword(user, password: pass) { result, e in
                        print("Login data: \(String(describing: result)), \(String(describing: e))")
                        client.sub("test-collection2", params:nil)
                        client.insert("test-collection2", document: NSArray(arrayLiteral:["_id":_id, "foo":"bar"]))
                    }
                }
                
                
                // the tuple that holds the subscription data in the client should be updated to reflect that the
                // subscription is ready
                let subscriptionID = client.findSubscription("test-collection2")
                print("subscriptionID ", subscriptionID)
                expect(client.subscriptionReady("test-collection2")).toEventually(beTrue(), timeout:5)
                
                // test that the data is returned from the server
                expect(added.count).toEventually(equal(1), timeout:5)
                expect(added[0]["foo"] as? String).toEventually(equal("bar"), timeout:5)
                
                // test that the data is removed from the server (can also me checked on the server)
                client.remove("test-collection2", document:NSArray(arrayLiteral:["_id":_id]))
                expect(removed.count).toEventually(equal(1), timeout:5)
                // expect(removed[0]).toEventually(equal("100"), timeout:5)
            }
            
            it ("can update a document in a collection") {
                var added = [NSDictionary]()
                var updated = [NSDictionary]()
                let client = MeteorClient()
                
                let _id = client.getId()
                
                client.events.onAdded = { collection, id, fields in
                    if ((collection == "test-collection2") && (_id == id)) {
                        added.append(fields!)
                    }
                }
                
                client.events.onChanged = { collection, id, fields, cleared in
                    if ((collection == "test-collection2") && (_id == id)) {
                        updated.append(fields!)
                    }
                }
               
                
                client.connect(url) { session in
                    print("Connected to DDP server!!! \(session)")
                    client.loginWithPassword(user, password: pass) { result, e in
                        print("Login data: \(String(describing: result)), \(String(describing: e))")
                        client.sub("test-collection2", params:nil)
                        client.insert("test-collection2", document: NSArray(arrayLiteral:["_id":_id, "foo":"bar"]))
                    }
                }
                
                expect(added.count).toEventually(equal(1), timeout:10)
                var params = NSMutableDictionary()
                params = ["$set":["foo":"baz"]]
                client.update("test-collection2", document: [["_id":_id], params]) { result, error in }
                expect(updated.count).toEventually(equal(1))
                client.remove("test-collection2", document: [["_id":_id]])
            }
            
            it ("can execute a method on the server that returns a value") {
                var response:String!
                let client = MeteorClient()
                
                client.connect(url) { session in
                    client.loginWithPassword(user, password: pass) { result, error in
                        client.method("test", params: nil) { result, error in
                            let r = result as! String
                            response = r
                        }
                    }
                }
                
                expect(response).toEventually(equal("test123"), timeout:5)
            }
        }
        
    }
}

