//
//  MeteorTests.swift
//  MeteorDDP_Tests
//
//  Created by Muhammad Ahsan Ali on 2020/04/12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import MeteorDDP


// TOOD:- Detail Unit tests
class MeteorTests: QuickSpec {
    
    override func spec() {
        
        MeteorLogger.loggingEnabled = false
        
        describe ("MeteorDDP Connection") {
            
            it ("can connect to a DDP server"){
                
                meteor.connect {
                    expect($0).toNotEventually(beNil(), timeout: 5)
                }
                
            }
            
            
            it ("loginWithUsername") {
                
                meteor.loginWithUsername(user, password: pass) { (result, error) in
                    self.expectResponse(result, error: error)
                    expect(meteor.userId).notTo(beNil())
                    expect(meteor.loggedInUser).notTo(beNil())
                    expect(meteor.isLoggedIn).toEventually(beTrue(), timeout: 5)
                    
                    self.collection_tests()
                    self.method_tests()
                    
                    
                }
                
            }
            
            it ("findSubscription") {
                
//                meteor.subscribe(collection, params: nil) {
//                    let subs = meteor.findSubscription(collection)
//                    expect(subs.count).to(equal(1))
//                    expect(meteor.subscriptionReady(collection)).to(beTrue())
//                }
            }
            
            logoutTests()

        }
        
        
    }
    
    func logoutTests() {
        it ("Logout") {
            meteor.logout { (result, error) in
                self.expectResponse(result, error: error)
                expect(meteor.userId).toEventually(beNil())
            }
        }
    }
    
    
    func collection_tests() {
        it ("Collection Tests for tasks") {
            var added = [MeteorKeyValue]()
            var updated = [MeteorKeyValue]()
            var removed = [String]()
            let _id = String.randomString
            
            meteor.addEventObserver(collection, event: .dataAdded) {
                guard let value = $0 as? MeteorDocument, (_id == value.id) else {
                    return
                }
                added.append(value.fields ?? [:])
            }
            
            meteor.addEventObserver(collection, event: .dataChange) {
                guard let value = $0 as? MeteorDocument, (_id == value.id) else {
                    return
                }
                updated.append(value.fields ?? [:])
            }
            
            meteor.addEventObserver(collection, event: .dataRemove) {
                guard let value = $0 as? MeteorDocument, (_id == value.id) else {
                    return
                }
                removed.append(value.id)
            }
            
            meteor.subscribe(collection, params:nil)

            expect(meteor.subscriptionReady(collection)).toEventually(beTrue(), timeout:5)
            expect(added.count).toEventually(equal(1), timeout:5)
            
        }
        
    }

    
    func method_tests() {
        it ("can execute a method on the server that returns a value") {
            var response:String!
            
            meteor.call(callName, params: nil) { result, error in
                let r = result as! String
                response = r
            }
            expect(response.count).to(equal(1))
        }
    }
    
    
    func expectResponse(_ result: Any?, error: MeteorError?) {
        expect(error).toEventually(beNil())
        expect(result).toNotEventually(beNil())
    }



}
