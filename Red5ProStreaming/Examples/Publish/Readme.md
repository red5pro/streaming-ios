#Publish Example

This example demonstrates the AdaptiveBitrateController, which provides a mechanism to dynamically adjust the video publishing bitrate to adjust quality to meet the bandwidth restrictions of the network connection or encoding hardware.

###Example Code
- ***[PublishExample.m](
https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/Examples/Publish/PublishExample.mm)***

- ***[BaseExample.m](
https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/BaseExample.m)***


##How to Publish
Publishing to a Red5 Pro stream requires a few components to function fully.
####Setup R5Connection
The R5Connection manages the connection that the stream utilizes.  You will need to setup a configuration and intialize a new connection.

```Objective-C
	//Setup a configuration object for our connection
    R5Configuration *config = [[R5Configuration alloc] init];
    config.host = [dict objectForKey:@"domain"];
    config.contextName = [dict objectForKey:@"context"];
    config.port = [(NSNumber *)[dict objectForKey:@"port"] intValue];
    config.protocol = 1;
    config.buffer_time = 1;
    
    //Create a new connection using the configuration above
    R5Connection *connection = [[R5Connection alloc] initWithConfig: config];
```
<sup>
[PublishExample.m #29](https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/Examples/Publish/PublishExample.m#L29)
</sup>

####Setup R5Stream
The `R5Stream` handles both subscribing and publishing.  Creating one simply requires the connection already created.

```	
	//Create our new stream that will utilize that connection
    self.publish = [[R5Stream alloc] initWithConnection:connection];
    
    //Setup our listener to handle events from this stream
    self.publish.delegate = self;

```
<sup>
[PublishExample.m #40](https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/Examples/Publish/PublishExample.m#L40)
</sup>

The `R5StreamDelegate` that is assigned to the `R5Stream` will receive status events for that stream, including connecting, disconnecting, and errors.

####Attach a Video Source
The R5Stream will need a video and/or audio source to stream from.  To attach a video source, you will need to create an `R5Camera` with the `AVCaptureDevice` you wish to stream from.

```
 	//Get a list of available cameras for this device
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    //Use the last device (front facing)
    AVCaptureDevice *videoDev = [devices lastObject];
    
    //Create an R5Camera with that device and specify the max bitrate to allow
    //Note : This bitrate will not be respected if it is lower than the encoder can go!
    R5Camera *camera = [[R5Camera alloc] initWithDevice:videoDev andBitRate:512];
    
    //Set up the resolution we want this camera to use.  This can only be set before publishing begins
    camera.width   = 640;
    camera.height  = 480;
    
    //Setup the rotation of the video stream.  This is meta data, and is used by the client to rotate the video.  No rotation is done on the publisher.
    camera.orientation = 90;
    
    //Add the camera to the stream
    [self.publish  attachVideo:camera];
```
<sup>
[PublishExample.m #47](https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/Examples/Publish/PublishExample.m#L47)
</sup>

`R5Camera.width` and `R5Camera.height` specify the encoded video size to be streamed.  `R5Camera` will choose the video format that is closest to this resolution from the camera.

`R5Camera.orientation` provides meta information to the stream for presentation on the client.  The video is not rotated by the device.  A value of **90** will provide portrait orientation on receiving devices.

####Attach an Audio Source
To add audio to a stream a `R5Microphone` object can be attached.  It behaves similarly to `R5Camera`, but requires `R5Stream.attachAudio` instead.

```
	//Setup a new R5Microphone for streaming audio with that device
    R5Microphone *microphone = [[R5Microphone new] initWithDevice:audioDevice];
    microphone.bitrate = 32;
    
    //Attach the microphone to the stream
    [self.publish attachAudio:microphone];

```

#### Preview the Publisher
The `R5VideoViewController` will present publishing streams as well as subscribed streams.  To preview a publishing stream, it simply needs to attach the `R5Stream`.  

***This is not required to publish - but allows for previewing the stream.***

A `R5VideoViewController` can be set on any UIViewController, or created programmatically

```
	-(R5VideoViewController *) getNewViewController: (CGRect) frame{
	    UIView *view = [[UIView alloc] initWithFrame: frame];
	    R5VideoViewController *viewController = [[R5VideoViewController alloc] init];
	    viewController.view = view;
	    return viewController;
	}
```
<sup>
[BaseExample.m #72](https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/BaseExample.m#L72)
</sup>

To view the preview before publishing as started, use `R5VideoViewController.showPreview`.

```
    [self addChildViewController:self.r5View];
    [self.view addSubview:self.r5View.view];
    
    //show the camera before we start!
    [self.r5View showPreview:YES];
    
    //show the debug information for the stream
    [self.r5View showDebugInfo:YES];
```
<sup>
[BaseExample.m #59](https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/BaseExample.m#L59)
</sup>

####Start Publishing
The `R5Stream.publish` method will establish the server connection and begin publishing.  

```
    //start publishing!
    [self.publish publish:[self getStreamName:PUBLISH] type:R5RecordTypeLive];
```
<sup>
[PublishExample.m #83](https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/Examples/Publish/PublishExample.m#L83)
</sup>

The *type* parameter tells the server the recording mode to use on the server.

- R5RecordTypeLive - Stream but do not record
- R5RecordTypeRecord - Stream and record the file name.  Replace existing save.
- R5RecordTypeAppend - Stream and append the recording to any existing save.
