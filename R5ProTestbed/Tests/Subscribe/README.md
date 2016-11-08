#Subscribing on Red5 Pro

This example shows how to easily subscribe to a Red5 Pro stream.

###Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[SubscribeTest.swift](SubscribeTest.swift)***

##How to Subscribe
Subscribing to a Red5 Pro stream requires a few components to function fully.
####Setup R5Connection
The R5Connection manages the connection that the stream utilizes.  You will need to setup a configuration and intialize a new connection.

```
Swift
func getConfig()->R5Configuration{
	// Set up the configuration
	let config = R5Configuration()
	config.host = Testbed.getParameter("host") as! String
	config.port = Int32(Testbed.getParameter("port") as! Int)
	config.contextName = Testbed.getParameter("context") as! String
	config.`protocol` = 1;
	config.buffer_time = Testbed.getParameter("buffer_time") as! Float
	return config
}
```
<sup>
[BaseTest.swift #50](../BaseTest.swift#L50)
</sup>
   
```
Swift 
let config = getConfig()
// Set up the connection and stream
let connection = R5Connection(config: config)
```
<sup>
[SubscribeTest.swift #27](SubscribeTest.swift#L27)
</sup>

####Setup R5Stream
The `R5Stream` handles both subscribing and publishing.  Creating one simply requires the connection already created.

```
Swift
//Create our new stream that will utilize that connection
self.publishStream = R5Stream(connection: connection)
//Setup our listener to handle events from this stream
self.publishStream!.delegate = self
```
<sup>
[BaseTest.swift #75](../BaseTest.swift#L75)
</sup>

The `R5StreamDelegate` that is assigned to the `R5Stream` will receive status events for that stream, including connecting, disconnecting, and errors.


#### Preview the Subscriber
The `R5VideoViewController` will present publishing streams as well as subscribed streams.  To view the subscribing stream, it simply needs to attach the `R5Stream`.  

A `R5VideoViewController` can be set on any UIViewController, or created programmatically

```
Swift
let r5View : R5VideoViewController = getNewR5VideoViewController(self.view.frame);
self.addChildViewController(r5View);
```
<sup>
[BaseTest.swift #121](../BaseTest.swift#L121)
</sup>

To view the preview before publishing has started, use `R5VideoViewController.showPreview`.

```
Swift
view.addSubview(r5View.view)

r5View.showPreview(true)

r5View.showDebugInfo(true)
```
<sup>
[BaseTest.swift #121](../BaseTest.swift#L121)
</sup>

Lastly, we attach the Stream to the R5VideoView to see the streaming content.

```
Swift
currentView?.attachStream(subscribeStream)
```
<sup>
[SubscribeTest.swift #34](SubscribeTest.swift#L34)
</sup>

####Start Subscribing
The `R5Stream.Subscribe` method will establish the server connection and begin Subscribing.  

```
Swift   
self.subscribeStream!.play(Testbed.getParameter("stream1") as! String)
```
<sup>
[SubscribeTest.swift #37](SubscribeTest.swift#L37)
</sup>
