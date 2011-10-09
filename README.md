## What Broker Is
Broker is the middleman between JSON payloads and your Core Data model.

## What Broker Isn't
Broker does not include a network solution; you must provide that layer yourself.  Sending and recieving data over the network is only weakly related to how you want to process it..  Big frameworks that try to solve multiple tangential problems should be avoided, as they are more complex and difficult to replace if and when something better comes along.

Broker doesn't work well with badly formed JSON.  By design, it is an extremely oppinionated and powerful bit of software, but with limited flexibility.  If you have control over the API you are interacting with, hopefully Broker will help you design a more usable and properly RESTful service.  If you don't have control and need to deal with nasty JSON, check out [RestKit](http://restkit.org/).

## The Problem
JSON is a great way to send and receive information when communicating with RESTful APIs.  With a Core Data backed iOS app, the trick is processing that JSON into objects described by your data model.  Existing solutions require you to basically duplicate your data model in code, creating explicit maps from network attributes to local attributes.  Not only that, but most also include the network layer as well, making it difficult to replace with better tech later on.

## How Broker Solves The Problem
*  When you register a Core Data entity with Broker, it builds a description of all entity properties based on your managed object using [ `NSEntityDescription`](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/CoreDataFramework/Classes/NSEntityDescription_Class/NSEntityDescription.html), [`NSAttributeDescription`](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/CoreDataFramework/Classes/NSAttributeDescription_Class/reference.html#//apple_ref/occ/cl/NSAttributeDescription), and [`NSRelationshipDescription`](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/CoreDataFramework/Classes/NSRelationshipDescription_Class/NSRelationshipDescription.html#//apple_ref/occ/cl/NSRelationshipDescription).
*  Property descriptions can include maps from network property names to local property names. For example, if your network Employee object has a property named `id`, you can map it to `employeeID`.
*  Broker uses [JSONKit](https://github.com/johnezang/JSONKit) alongside property descriptions to serialize and deserialize JSON.  Supah fast.

## How To Use Broker
Once you have your data model built, the first step is to setup Broker with your models managed object context.

	[Broker setupWithContext:myContext];
 
Next is to register entities that you want to send/receive via JSON.

	[Broker registerEntityNamed:@"Employee"];

You may need to map a property name:

	[Broker registerEntityNamed:@"Employee" andMapNetworkProperty:@"id" toLocalProperty:@"employeeID"];

Or map multiple property names:

	[Broker registerEntityNamed:@"Employee" andMapNetworkProperties:[NSArray arrayWithObjects:@"id", @"first_name", nil] toLocalProperties:[NSArray arrayWithObjects:@"employeeID", @"firstname", nil]];

As far as setup, that's really it.  From here you can take JSON payloads and point them to specific objects saved in your store using object URIs.

	[Broker parseJSONPayload:jsonPayload targetEntity:employeeURI];

This kicks off a couple async queues to both parse the JSON and set property values on the target entity.

Notes
-------------------------

This is beta software.  Stay tuned for updates and a official versioned release.

