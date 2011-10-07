Introduction
=========================
Broker is the middleman between JSON resources and your Core Data model.  Use Broker to parse returned JSON and process the result onto registered Core Data entities.

## The Problem

JSON is a great way to send and receive information when communicating with RESTful APIs.  With a Core Data backed iOS app, the trick is processing that JSON into objects and setting appropriate properties as described by your object model.

## How Broker Works

Broker is designed to sit next to your network layer to take JSON payloads and process asynchronously into Core Data objects.
Broker uses [JSONKit](https://github.com/johnezang/JSONKit) for super fast parsing of JSON data returned from your network layer.   

Notes
-------------------------

Hella beta.  Forks, patches and other feedback are always welcome. 

