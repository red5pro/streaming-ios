# Publishing on Red5 Pro

This is the basic starter example on publishing to a Red5 Pro stream. 

### Example Code
- ***[BaseTest.swift](../BaseTest.swift)***
- ***[PublishTest.swift](PublishTest.swift)***

## How to Publish

Publishing to a Red5 Pro stream requires a few components to function fully.

#### Setup R5Connection

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
[PublishTest.swift #27](PublishTest.swift#L27)
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

####Attach a Video Source
The R5Stream will need a video and/or audio source to stream from.  To attach a video source, you will need to create an `R5Camera` with the `AVCaptureDevice` you wish to stream from.

```
Swift
//Use the last device in the list of available cameras
let videoDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).last as? AVCaptureDevice 
//Create an R5Camera with that device and specify the max bitrate to allow
//Note : This bitrate will not be respected if it is lower than the encoder can go! 
let camera = R5Camera(device: videoDevice, andBitRate: Int32(Testbed.getParameter("bitrate") as! Int))
//Set up the resolution we want this camera to use.  This can only be set before publishing begins
camera.width = 900
camera.height = 600
//Setup the rotation of the video stream.  This is meta data, and is used by the client to rotate the video.  No rotation is done on the publisher.
camera.orientation = 90
//Add the camera to the stream
self.publishStream!.attachVideo(camera)
```
<sup>
[BaseTest.swift #83](../BaseTest.swift#L83)
</sup>

`R5Camera.width` and `R5Camera.height` specify the encoded video size to be streamed.  `R5Camera` will choose the video format that is closest to this resolution from the camera.

`R5Camera.orientation` provides meta information to the stream for presentation on the client.  The video is not rotated by the device.  A value of **90** will provide portrait orientation on receiving devices.

####Attach an Audio Source
To add audio to a stream a `R5Microphone` object can be attached.  It behaves similarly to `R5Camera`, but requires `R5Stream.attachAudio` instead.

```
Swift
//Setup a new R5Microphone for streaming audio with that device
let audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
let microphone = R5Microphone(device: audioDevice)
microphone.bitrate = 32
microphone.device = audioDevice;
NSLog("Got device %@", audioDevice)
//Attach the microphone to the stream
self.publishStream!.attachAudio(microphone)
```
<sup>
[BaseTest.swift #92](../BaseTest.swift#L92)
</sup>

#### Preview the Publisher
The `R5VideoViewController` will present publishing streams as well as subscribed streams.  To preview a publishing stream, it simply needs to attach the `R5Stream`.  

***This is not required to publish - but allows for previewing the stream.***

An `R5VideoViewController` can be set on any UIViewController, or created programmatically

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
self.currentView!.attachStream(publishStream!)
```
<sup>
[PublishTest.swift #35](PublishTest.swift#L35)
</sup>

#### Start Publishing

The `R5Stream.publish` method will establish the server connection and begin publishing.  

```
Swift
self.publishStream!.publish(Testbed.getParameter("stream1") as! String, type: R5RecordTypeLive)
```

[PublishTest.swift #38](PublishTest.swift#L38)

The *type* parameter tells the server the recording mode to use on the server.

- **R5RecordTypeLive** - Stream but do not record
- **R5RecordTypeRecord** - Stream and record the file name.  Replace existing save.
- **R5RecordTypeAppend** - Stream and append the recording to any existing save.

#### View your stream

Open a browser window and navigate to http://your_red5_pro_server_ip:5080//live/subscribe.jsp to see a list of active streams. Click on the _flash version to subscribe to your stream.