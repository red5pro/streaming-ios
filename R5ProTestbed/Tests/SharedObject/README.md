# Shared Objects

This example demonstrates the use of Remote Shared Objects, which provides a mechanism to share and persist information across mutiple clients in real time, as well as sending messages to all clients that are connected to the object.

### Example Code
- ***[BaseTest.swift](../BaseTest.swift)***
- ***[SharedObjectTest.swift](SharedObjectTest.swift)***

### Setup
Use of Shared objects requires an active stream - either publishing or subscribing. The content of the stream isn't important to the shared object itself, even a muted audio-only stream will be enough. Also, which stream you are connected to isn't important to which shared object you access, meaning that clients across multiple streams can use the same object, or there could be multiple overlapping objects in the same stream.

To run the test, you will need at least two devices running the "Shared Object" example. This example searches active streams for the stream name set as 'stream1' in tests.plist. If a client doesn't find an active stream with that name, it will begin publishing that stream, while any device that finds the published stream will subscribe to it.

### Swift3 vs Objective C Note
The Shared Object interfaces are written for Objective C, however they can still be used in Swift3. Anywhere that "array" is mentioned, it refers to NSArray or NSMutableArray in Objective C and a [Any] object in Swift3. "Dictionary" refers to NSDictionary of NSMutableDictionary in Objective C and a [AnyHashable: Any] object in Swift3.

While Swift3 does have NSArray and NSDictionary objects, they do not translate into Objective C and will cause errors.

### Connection
Shared objects require a successfully started stream to transmit data. There is sometimes a slight delay between receiving the server message that the stream has started and when it will accept connection calls such as the Shared Object connection request - this delay will usually be a small fraction of a second, but still needs to be accounted for.

```Swift
override func onR5StreamStatus( _ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        super.onR5StreamStatus(stream, withStatus: statusCode, withMessage: msg)

        if(Int(statusCode) == Int(r5_status_start_streaming.rawValue)){

            self.timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(SOConnect), userInfo: nil, repeats: false)
        }
    }
```
<sup>
[SharedObjectTest.swift #132](../SharedObjectTest.swift#L132)
</sup>

Instantiating a new R5SharedObject requires a name and the connection used for your stream. After that it will connect and notify the object set as its client that it has connected successfully.

```Swift
sObject = R5SharedObject(name:"sharedChatTest", connection: stream?.connection);
sObject?.client = self;
```
<sup>
[SharedObjectTest.swift #145](../SharedObjectTest.swift#L145)
</sup>

Once connected successfully, the shared object will attempt to call `onSharedObjectConnect` on the client object - passing a dictionary with the object's current state as a parameter.

To disconnect, simply call `close()` on the object. This should be called before closing the stream whose connection the object shares.

### Persistent Information
Remote Shared Objects use JSON for transmission, meaning that its structure is primarily up to your discretion. The base object will always be a dictionary with string keys, while values can be strings, numbers, booleans, arrays, or other dictionaries - with the same restriction on sub-objects.

This example simply uses a number to keep a count of how many people are connected to the object. As seen in `onSharedObjectConnect`, value can be accessed from the object by name, and set using `setProperty`

```Swift
addMessage(message: "Connected to object, there are " + ((objectValue["count"] != nil) ? String(describing: objectValue["count"]) : "no") + " other people connected");
thisUser = (objectValue["count"] != nil) ? (objectValue["count"] as! Int) + 1 : 1;
//set the count property to add yourself
sObject?.setProperty("count", withValue: (objectValue["count"] != nil ? (objectValue["count"] as! Int) + 1 : 1) as NSNumber)
```
<sup>
[SharedObjectTest.swift #150](../SharedObjectTest.swift#L150)
</sup>

When one client calls `setProperty` other clients will be notified through `onUpdateProperty` with a dictionary that holds the single key/value pair that has updated.

```Swift
func onUpdateProperty( propertyInfo: [AnyHashable: Any] ) {
    //propertyInfo.keys[0] can be used to find which property has updated.
    addMessage(message: "Room update - There are now " + String(describing: propertyInfo["count"]) + " users")
}
```
<sup>
[SharedObjectTest.swift #175](../SharedObjectTest.swift#L175)
</sup>

Note that the read-only data property of the R5SharedObject which holds the current state of the remote object is updated before a method is called on the client.

### Messages
The Shared Object interface also allows sending messages to other people watching the object. By sending a dictionary through the `send` method, that object will be passed to all the listening clients that implement the specified call.

```Swift
let messageOut : [AnyHashable:Any] = [ "user":String(thisUser), "message":(chatInuput?.text)! ]

//Calls for the relevant method with the sent parameters on all clients listening to the shared object
//Note - This includes the client that sends the call
sObject?.send("messageTransmit", withParams: messageOut)
```
<sup>
[SharedObjectTest.swift #165](../SharedObjectTest.swift#L165)
</sup>

Which is received by:

```Swift
func messageTransmit( messageIn: [AnyHashable: Any] ){

  let user: String = messageIn["user"] as! String
  let message : String = messageIn["message"] as! String
```
<sup>
[SharedObjectTest.swift #180](../SharedObjectTest.swift#L180)
</sup>

Like with the parameters of the object, as long as the dictionary sent parses into JSON, the structure of the object is up to you, and it will reach the other clients in whole as it was sent.
