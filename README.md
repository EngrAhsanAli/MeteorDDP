

![MeteorDDP](https://raw.githubusercontent.com/EngrAhsanAli/MeteorDDP/master/MeteorDDP.png)


# MeteorDDP 🇵🇰 🇯🇵 

A client for Meteor servers, written in Swift 5!

## Table of Contents

  

-  [MeteorDDP](#section-id-4)

- [Description](#section-id-10)

- [Demonstration](#section-id-16)

- [Requirements](#section-id-26)

-  [Installation](#section-id-32)

-  [CocoaPods](#section-id-37)

-  [Carthage](#section-id-63)

- [Manual Installation](#section-id-82)

- [Getting Started](#section-id-87)

- [Contributions & License](#section-id-156)

  

  

<div id='section-id-4'/>

  

## MeteorDDP


[![Swift 5.0](https://img.shields.io/badge/Swift-5.1-orange.svg?style=flat)](https://developer.apple.com/swift/)  [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)  [![CocoaPods](https://img.shields.io/cocoapods/v/MeteorDDP.svg)](http://cocoadocs.org/docsets/MeteorDDP)  [![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://github.com/Carthage/Carthage)  [![Build Status](https://travis-ci.org/EngrAhsanAli/MeteorDDP.svg?branch=master)](https://travis-ci.org/EngrAhsanAli/MeteorDDP)

![License MIT](https://img.shields.io/github/license/mashape/apistatus.svg)  [![CocoaPods](https://img.shields.io/cocoapods/p/MeteorDDP.svg)]()

  

  

<div id='section-id-10'/>

  

# Description

A version of  [SwiftDDP](https://github.com/siegesmund/SwiftDDP)  for [Meteor](https://github.com/meteor/meteor) servers, written in Swift 5! 

**Credits of this library go to [SwiftDDP](https://github.com/siegesmund/SwiftDDP) author and it is just a replica of SwiftDDP which is compatible with Swift 5 and Xcode 11. Future enhancements and updates of this library are expected**


MeteorDDP is really helpful to integrate servers written in meteor (a framework written in javascript) using native Swift in iOS.

> Meteor is a Node-based full-stack framework which allows to create
> reactive webapps, that could easily be ported to Android and iOS
> platforms. Reactive webapp implies real-time behaviour: There is a
> continuous connection between the client and server side, and so, a
> change made in application by any means(direct entry in database, from
> server, or even by a client) is reflected on every instance of the
> application without any page reload.
  

<div id='section-id-16'/>

  

## Demonstration

`MeteorDDP` A client for Meteor servers, written in Swift 5

To run the example project, clone the repo, and run `pod install` from the Example directory first.

<div id='section-id-26'/>

## Requirements

  

- iOS 8.0+

- Xcode 11.0+

- Swift 5+

 
<div id='section-id-32'/>

## Installation

`MeteorDDP` can be installed using CocoaPods, Carthage, or manually.

<div id='section-id-37'/>  

## CocoaPods

  

`MeteorDDP` is available through [CocoaPods](http://cocoapods.org). To install CocoaPods, run:

`$ gem install cocoapods`

Then create a Podfile with the following contents:

```swift

source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'

use_frameworks!

target '<Your Target Name>' do

pod 'MeteorDDP'

end

```

Finally, run the following command to install it:

```

$ pod install

```

<div id='section-id-63'/>

  

## Carthage

To install Carthage, run (using Homebrew):

```

$ brew update

$ brew install carthage

```

Then add the following line to your Cartfile:

```

github "EngrAhsanAli/MeteorDDP" "master"

```

Then import the library in all files where you use it:

```swift

import MeteorDDP

```

<div id='section-id-82'/>

  

##Manual Installation

If you prefer not to use either of the above mentioned dependency managers, you can integrate `MeteorDDP` into your project manually by adding the files contained in the Classes folder to your project.

<div id='section-id-87'/>

# Getting Started

Following is the example to configure meteor in swift.

<div id='section-id-90'/>

****Usage****:

Setting basic configuration options

```swift
Meteor.client.allowSelfSignedSSL = true // Connect to a server that uses a self signed ssl certificate
Meteor.client.logLevel = .Info  // Options are: .Verbose, .Debug, .Info, .Warning, .Error, .Severe, .None
```
Connecting to a Meteor server

```swift
Meteor.connect("wss://todos.meteor.com/websocket") {
// do something after the client connects
}
```

Login using email and password.
```swift
Meteor.loginWithPassword("user@MeteorDDP.com", password: "********") { result, error in
// do something after login
}
```

Login using username and password.

```swift
Meteor.loginWithUsername("MeteorDDP", password: "********") { result, error in
// do something after login
}
```

Log out.

```swift
Meteor.logout() { result, error in
// do something after logout
}
```

The client also posts a notification when the user signs in and signs out, and during connection failure events.  

```swift

public enum MeteorNotificationType: String  {

case userDidLogin,userDidLogout, socketDidClose, socketError, socketDidDisconnected, socketFailed, collectionDidChange

}

// Example
NotificationCenter.default.addObserver(
    self,
    selector: #selector(self.userDidLogin),
    name: "userDidLogin",
    object: nil)


NotificationCenter.default.addObserver(
    self,
    selector: #selector(self.userDidLogout),
    name: "userDidLogout",
    object: nil)
 
func userDidLogin() {
	print("The user just signed in!")
}

func userDidLogout() {
	print("The user just signed out!")
}
```

#### Subscribe to a subset of a collection

```swift
Meteor.subscribe("todos")

Meteor.subscribe("todos") {
    // Do something when the todos subscription is ready
}

Meteor.subscribe("todos", [1,2,3,4]) {
    // Do something when the todos subscription is ready
}
```

#### Change the subscription's parameters and manage your subscription with unsubscribe
```swift

// Suppose you want to subscribe to a list of all cities and towns near a specific major city

// Subscribe to cities near Boston
let id1 = Meteor.subscribe("cities", ["lat": 42.358056 ,"lon": -71.063611]) {
    // You are now subscribed to cities associated with the coordinates 42.358056, -71.063611
    // id1 contains a key that allows you to cancel the subscription associated with 
    // the parameters ["lat": 42.358056 ,"lon": -71.063611]
}

// Subscribe to cities near Paris
let id2 = Meteor.subscribe("cities", ["lat": 48.8567, "lon": 2.3508]){
    // You are now subscribed to cities associated with the coordinates 48.8567, 2.3508
    // id2 contains a key that allows you to cancel the subscription associated with 
    // the parameters ["lat": 48.8567 ,"lon": 2.3508]
}

// Subscribe to cities near New York
let id3 = Meteor.subscribe("cities", ["lat": 40.7127, "lon": -74.0059]){
    // You are now subscribed to cities associated with the coordinates 40.7127, -74.0059
    // id3 contains a key that allows you to cancel the subscription associated with 
    // the parameters ["lat": 40.7127 ,"lon": -74.0059]
}

// When these subscriptions have completed, the collection associated with "cities" will now contain all
// documents returned from the three subscriptions

Meteor.unsubscribe(withId: id2) 
// Your collection will now contain cities near Boston and New York, but not Paris
Meteor.unsubscribe("cities")    
// You are now unsubscribed to all subscriptions associated with the publication "cities"
```

#### Call a method on the server

```swift
Meteor.call("foo", [1, 2, 3, 4]) { result, error in
    // Do something with the method result
}
```
When passing parameters to a server method, the parameters object must be serializable with **NSJSONSerialization**

#### Simple in-memory persistence
MeteorDDP includes a class called MeteorCollection that provides simple, ephemeral dictionary backed persistence. MeteorCollection stores objects subclassed from MeteorDocument. Creating a collection is as simple as:

```swift
class List: MeteorDocument {

    var collection:String = "lists"
    var name:String?
    var userId:String?

}

let lists = MeteorCollection<List>(name: "lists")   // As with Meteorjs, the name is the name of the server-side collection  
Meteor.subscribe("lists")
```
For client side insertions, updates and removals:

```swift
let list = List(id: Meteor.client.getId(), fields: ["name": "foo"])

// Insert the object on both the client and server.
lists.insert(list)

// Update the object on both the client and server
list.name = "bar"
lists.update(list)

// Remove the object on both the client and server
lists.remove(list)
```
For each operation the action is executed on the client, and rolled back if the server returns an error.

#### Tips for CLI

If you make a command line tool, you need to call the function dispatchMain in main thread after proper DDP settings. Otherwise, you will encounter a dead lock.

```swift
Meteor.connect("wss://todos.meteor.com/websocket") {
    // do something after the client connects
}
dispatchMain()
```


## Example: Creating an array based custom collection
**The following pattern can be used to create custom collections backed by any datastore**

In this example, we'll create a simple collection to hold a list of contacts. The first thing we'll do is create an object to represent a contact. This object has four properties and a method named *update* that maps the *fields* NSDictionary to the struct's properties. *Update* is called when an object is created and when an update is performed. Meteor will always transmit an **id** to identify the object that should be added, updated or removed, so objects that represent Meteor documents must **always** have an id field. Here we're sticking to the MongoDB convention of naming our id *_id*.

```swift

struct Contact {

    var _id:String?
    var name:String?
    var phone:String?
    var email:String?

    init(id:String, fields:NSDictionary?) {
        self._id = id
        update(fields)
    }

    mutating func update(fields:NSDictionary?) {

        if let name = fields?.valueForKey("name") as? String {
            self.name = name
        }

        if let phone = fields?.valueForKey("phone") as? String {
            self.phone = phone
        }

        if let email = fields?.valueForKey("email") as? String {
            self.email = email
        }
    }
}

```
Next, we'll create the collection class that will hold our contacts and provide the logic to respond to server-side changes to the documents and the subscription set. MeteorDDP contains an abstract class called AbstractCollection that can be used to build custom collections. Subclassing AbstractCollection allows you to override three methods that are called in response to events on the server: *documentWasAdded*, *documentWasChanged* and *documentWasRemoved*.

```swift
class UserCollection: AbstractCollection {

    var contacts = [Contact]()

    // Include any logic that needs to occur when a document is added to the collection on the server
    override public func documentWasAdded(collection:String, id:String, fields:NSDictionary?) {
        let user = User(id, fields)
        users.append(user)
    }

    // Include any logic that needs to occur when a document is changed on the server
    override public func documentWasChanged(collection:String, id:String, fields:NSDictionary?, cleared:[String]?) {
        if let index = contacts.indexOf({ contact in return contact._id == id }) {
            contact = contacts[index]
            contact.update(fields)
            contacts[index] = contact
        }
    }

  // Include any logic that needs to occur when a document is removed on the server
  override public func documentWasRemoved(collection:String, id:String) {
    if let index = contacts.indexOf({ contact in return contact._id == id }) {
        contacts[index] = nil
        }
    }
}
```
So far, we're able to process documents that have been added, changed or removed on the server. But the UserCollection class still lacks the ability to make changes to both the local datastore and on the server. We'll change that. In the UserCollection class, create a method called insert.

```swift
class UserCollection: AbstractCollection {
    /*
    override public func documentWasAdded ...
    override public func documentWasChanged ...
    override public func documentWasRemoved ...
    */

    public func insert(contact: Contact) {

        // (1) save the document to the contacts array
        contacts[contacts._id] = contact

        // (2) now try to insert the document on the server
        client.insert(self.name, document: [contacts.fields()]) { result, error in

            // (3) However, if the server returns an error, reverse the action on the client by
            //     removing the document from the contacts collection
            if error != nil {
                self.contacts[contact._id] = nil
                log.error("\(error!)")
            }

        }

    }
}
```
The key parts of this method are:
- (1) save the new contact to the array we created in UserCollection
- (2) invoke client.insert to initiate an insert on the server
- (3) remove the contact from the local store if the server rejects the insert

Creating update and remove methods are also easy to create, and follow the same patern as insert. For a more extensive example of the patterns shown here, have a look at *MeteorCollection.swift*
MeteorCollection is an in-memory collection implementation suitable for simple applications.
<div id='section-id-156'/>

  

#Contributions & License

`MeteorDDP` is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.

Pull requests are welcome! The best contributions will consist of substitutions or configurations for classes/methods known to block the main thread during a typical app lifecycle.

Follow and support us **Meteor Pakistan** on [facebook](https://www.facebook.com/meteorpk) 

I would love to know if you are using `MeteorDDP` in your app, send an email to [Engr. Ahsan Ali](mailto:hafiz.m.ahsan.ali@gmail.com)
