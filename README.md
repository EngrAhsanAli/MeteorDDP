![MeteorDDP](https://raw.githubusercontent.com/EngrAhsanAli/MeteorDDP/master/MeteorDDP.png)

# MeteorDDP 🇵🇰 🇯🇵

A client for Meteor servers, written in Swift 5!

Following web sockets methods are used to connect [MeteorDDP](https://github.com/EngrAhsanAli/MeteorDDP) to [Meteor](%5Bhttps://www.meteor.com/%5D%28https://www.meteor.com/%29) Servers.

- [Starscream](https://github.com/daltoniam/Starscream) Min iOS 8
- [URLSessionWebSocketTask](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask) Min iOS 13

## Table of Contents

-  [MeteorDDP](#section-id-4)
-  [Description](#section-id-10)
- [Demonstration](#section-id-16)
-  [Requirements](#section-id-26)
-  [Installation](#section-id-32)
-  [CocoaPods](#section-id-37)
-  [Carthage](#section-id-63)
- [Manual Installation](#section-id-82)
- [Getting Started](#section-id-87)
- [Contributions & License](#section-id-156)

<div id='section-id-4'/>

## MeteorDDP

[![Swift 5.1.2](https://img.shields.io/badge/Swift-5.1.2-orange.svg?style=flat)](https://developer.apple.com/swift/)  [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)  [![CocoaPods](https://img.shields.io/cocoapods/v/MeteorDDP.svg)](http://cocoadocs.org/docsets/MeteorDDP)  [![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://github.com/Carthage/Carthage)  [![Build Status](https://travis-ci.org/EngrAhsanAli/MeteorDDP.svg?branch=master)](https://travis-ci.org/EngrAhsanAli/MeteorDDP)

![License MIT](https://img.shields.io/github/license/mashape/apistatus.svg)  [![CocoaPods](https://img.shields.io/cocoapods/p/MeteorDDP.svg)]()

<div id='section-id-10'/>

# Description


Inspired from [SwiftDDP](https://github.com/siegesmund/SwiftDDP) for [Meteor](https://github.com/meteor/meteor) servers, written in Swift 5!

MeteorDDP is really helpful to integrate servers written in meteor (a framework written in javascript) using native Swift in iOS.

> Meteor is a Node-based full-stack framework which allows to create reactive webapps, that could easily be ported to Android and iOS platforms. Reactive webapp implies real-time behaviour: There is a continuous connection between the client and server side, and so, a change made in application by any means(direct entry in database, from server, or even by a client) is reflected on every instance of the application without any page reload.

<div id='section-id-16'/>

## Demonstration

`MeteorDDP` is client for Meteor servers for iOS platform, which provides observers for all changes in events binded through a meteor server. 

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

Then import the library in all files where you use it and the global instance:

```swift
import MeteorDDP

let meteor: MeteorClient = {
MeteorClient(url: url, webSocket: .webSocketTask, requestTimeout: 15)
}()
// By default the preferred websocket method is starscream
```

<div id='section-id-82'/>

##Manual Installation

If you prefer not to use either of the above mentioned dependency managers, you can integrate `MeteorDDP` into your project manually by adding the files contained in the Classes folder to your project and create the global instance as mentioned below.

<div id='section-id-87'/>

# Getting Started

Following is the example to configure meteor in swift.

<div id='section-id-90'/>


```swift

let meteor: MeteorClient = {
MeteorClient(url: url, webSocket: .starscream)
}()

// Global meteor subscriptions manager (optional to manage through this way)
let meteorCollection: MeteorCollections = {
MeteorCollections(client: meteor)
}()

MeteorLogger.loggingEnabled = true

```
Connecting to a Meteor server
```swift

meteor.connect {
// do something after the client connects
}
```

Login using email and password.

```swift

meteor.loginWithPassword("ali@meteorDDP.com", password: "********") { (result, error) in 
if error != nil {
//Login Failed
}
else {
// do something after login
}
}
```

Login using username and password.

```swift
meteor.loginWithUsername("Ali", password: "********") { (result, error) in 
if error != nil {
//Login Failed
}
else {
// do something after login
}
}

```

Login anyway (either with valid email or username).

```swift
meteor.login("Ali", password: "********") { (result, error) in 
if error != nil {
//Login Failed
}
else {
// do something after login
}
}

```

Log out.

```swift

meteor.logout { (result, error) in
if error != nil {
//Logout Failed
}
else {
// do something after logout
}
}
```

Disconnect MeteorDDP.

```swift

meteor.disconnect()

```


## Subscribe

#### Subscribe and unsubscribe to a subset of a collection

```swift
meteor.subscribe("todos", [1,2,3,4]) {
// Do something when the todos subscription is ready
}

meteor.unsubscribe("SubID") {
// Unsubscribed of SubID
}

meteor.unsubscribe(withName: "todos") {
// Unsubscribed from todos
}

meteor.unsubscribeAll {
// Unsubscribed to all 
}

```

#### Manage through subscription manager

```swift

// First subscribe with name
meteorCollection.subscribe("todos", params: nil) { events, document in
// Do something when the todos subscription is ready
}

// Listen to collection changes
meteorCollection.collectionDidChange = { collection in
// collection.documents new or changed dataset
}

// Add observer to some event, like dataAdded, dataChange or dataRemove
meteor.addEventObserver("todos", event: .dataAdded) {
guard let value = $0 as? MeteorDocument else {
return
}
// value.id is the unique ID of MeteorDocument
self.documents[value.id] = value.fields
}

// Optionally remove events registered against subscription
meteor.removeEventObservers("todos", event: [.dataAdded, .dataChange, .dataRemove]) 

// Unsubscribe 
meteorCollection.unsubscribe("todos")
```

#### Update collection from client

```swift

// operation could be insert, remove or update against given meteor document
// keyValue is the update request to meteor server against that collection
meteor.updateColection("todos", type: .update, documents: [["_id": "MeteorDocumentID"],["$set": keyValue]]) { (res, error) in
if error == nil {
// Successfully updated
}
}

```

## Call a method

```swift
meteor.call("tasks.insert", params: [textField.text!]) { (res, error) in
if error == nil && res != nil {
// do something with the response
}
}

```

# Observers

#### Delegate

**MeteorDelegate** could receive the udpates in single method described below

```swift
meteor.delegate = self

func didReceive(name: MeteorEvents, event: Any) {

switch name {
case .method:
// event -> MeteorMethod object
case .websocket:
// event -> WebSocketEvent, could be connected, disconnected, text, error
case .dataAdded:
// event -> MeteorDocument object
case .dataChange:
// event -> MeteorDocument object
case .dataRemove:
// event -> MeteorDocument object
}
}
```

#### Callback

Simple add the observer with specified event anywhere in your code!

```swift

// Event could be any as mentioned in MeteorDelegate
meteor.addEventObserver("todos", event: .dataAdded) { 
// $0 is the data against that event
}

```

# MeteorEncodable

Below helper methods are available to encode or decode an object

```swift

MeteorEncodable.encode
MeteorEncodable.decode

```

# MeteorOAuth

MeteorOAuthViewController

```swift

// MeteorLoginService are twitter, github, google, facebook
// MeteorOAuthViewController is to present MeteorOAuth

```

<div id='section-id-156'/>

#Contributions & License

`MeteorDDP` is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.

Pull requests are welcome! The best contributions will consist of substitutions or configurations for classes/methods known to block the main thread during a typical app lifecycle.

Follow and support us ****Meteor Pakistan**** on [facebook](https://www.facebook.com/meteorpk)

I would love to know if you are using `MeteorDDP` in your app, send an email to [Engr. Ahsan Ali](mailto:hafiz.m.ahsan.ali@gmail.com)
