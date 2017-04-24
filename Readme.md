# Red5 Pro iOS Streaming Testbed

This repository contains a simple project with a number of examples that can be used for testing and reference.

## Requirements

* [Red5 Pro Server](#red5-pro-server)
* [Red5 Pro SDK License Key](#red5-pro-sdk-license-key)

### Red5 Pro Server
You will need a functional, running Red5 Pro server web- (or locally-) accessible for the client to connect to. If you already have a [Red5 Pro Account](https://account.red5pro.com), you can find the Red5 Pro Server download at [https://account.red5pro.com/download](https://account.red5pro.com/download).

> For more information visit [Red5Pro.com](https://red5pro.com).

### Red5 Pro SDK License Key
A Red5 Pro SDK License Key is required to use the iOS Mobile SDK. If you already have a [Red5 Pro Account](https://account.red5pro.com), you can find your Red5 Pro SDK License Key at [https://account.red5pro.com/overview](https://account.red5pro.com/overview).

> You will need to copy the `SDK License` into the `license_key` property field of the [tests.plist](R5ProTestbed/tests.plist).

## Setup

You will need to modify **/Red5ProTestbed/tests.plist (the domain value)** to point to your `host` server instance's IP address and update the `license_key` property to that of your Red5 Pro SDK License.  If you do not, the examples will not function when you build. If you are running the server locally, then your machine and mobile device need to be on the same WiFi network. 

Once you have modified your settings, you can run the application for simulator or device.

> ***Note: Publishing does not currently work on simulator!***

##Examples

###[Publishing](R5ProTestbed/Tests/Publish)

| **[1080p](R5ProTestbed/Tests/Publish)**                 
| :-----
| *A high quality publisher. Note that this is the publish test with a non-default 'bitrate' and camera size values set in tests.plist* 
|
| **[ABR](R5ProTestbed/Tests/AdaptiveBitrate)**
| *A high bitrate publisher with AdaptiveBitrateController*   
|
| **[Camera Swap](R5ProTestbed/Tests/CameraSwap)**
| *Touch the screen to swap which camera is being used! erify with flash, android, or other iOS device running subscribe test that camera is swapping properly and no rendering problems occur.* 
|
| **[Mute/Unmute](R5ProTestbed/Tests/PublishPause)**
| *Touch the screen to toggle between sending Audio & Video, sending just Video, sending just Audio, and sending no Audio or Video. Turning off and on the media sources is considered mute and unmute events, respecitively* 
|
| **[Custom Video Source](R5ProTestbed/Tests/PublishCustomSource)**
| *Uses a custom controller to supply video data to the publisher.*
|
| **[Image Capture](R5ProTestbed/Tests/PublishStreamImage)**
| *Touch the publish stream to take a screen shot that is displayed!* 
|
| **[Device Orientation](R5ProTestbed/Tests/PublishDeviceOrientation)**
| *Rotate the device to update the orientation of the broadcast stream.  Verify with browser-based players (WebRTC, Flash, HLS), Android, or other iOS device running subscribe test that image is rotating properly and no rendering problems occur.*
|
| **[Orientation](R5ProTestbed/Tests/PublishOrientation)**
| *Touch the screen to rotate the output video 90 degrees.  Verify with browser-based players (WebRTC, Flash, HLS), Android, or other iOS device running subscribe test that image is rotating properly and no rendering problems occur.*    
|
| **[Record](R5ProTestbed/Tests/Recorded)**
| *A publish example that records stream data on the server.*
|
| **[Remote Call](R5ProTestbed/Tests/RemoteCall)**
| *The publish portion of the remote call example - sends the remote call.*
| 
| **[Stream Manager](R5ProTestbed/Tests/PublishStreamManager)**
| *A publish example that connects with a server cluster using a Stream Manger*
|
| **[Two Way](R5ProTestbed/Tests/TwoWay)**
| *An example of simultaneously publishing while subscribing - allowing a conversation. Includes stream detection and auto-connection.*

###[Subscribing](R5ProTestbed/Tests/Subscribe)

| **[Aspect Ratio](R5ProTestbed/Tests/SubscribeAspectRatio)**
| :----
| *Change the fill mode of the stream.  scale to fill, scale to fit, scale fill.  Aspect ratio should be maintained on first 2.*  
|
| **[Cluster](R5ProTestbed/Tests/SubscribeCluster)** 
| *An example of conecting to a cluster server.*
|
| **[Image Capture](R5ProTestbed/Tests/SubscribeStreamImage)**
| *Touch the subscribe stream to take a screen shot that is displayed!*
|
| **[No View](R5ProTestbed/Tests/SubscribeNoView)**
| *A proof of using an audio only stream without attaching it to a view.*
|
| **[Reconnect](R5ProTestbed/Tests/SubscribeReconnect)**
| *An example of reconnecting to a stream on a connection error.*
|
| **[Remote Call](R5ProTestbed/Tests/RemoteCall)**
| *The subscribe portion of the remote call example - receives the remote call.* 
| 
| **[Stream Manager](R5ProTestbed/Tests/SubscribeStreamManager)**
| *A subscribe example that connects with a server cluster using a Stream Manger* 
|
| **[Two Streams](R5ProTestbed/Tests/SubscribeTwoStreams)**
| *An example of subscribing to multiple streams at once, useful for subscribing to a presentation hosted by two people using a Two Way connection.*


     
##Notes

1. For some of the above examples you will need two devices (a publisher, and a subscriber). You can also use a web browser to subscribe or publish via Flash, http://your_red5_pro_server_ip:5080/live.
2. You can see a list of active streams by navigating to http://your_red5_pro_server_ip:5080/live/subscribe.jsp (will need to refresh this page after you have started publishing).
3. Click on the *flash* link to view the published stream in your browser.

[![Analytics](https://ga-beacon.appspot.com/UA-59819838-3/red5pro/streaming-ios?pixel)](https://github.com/igrigorik/ga-beacon)