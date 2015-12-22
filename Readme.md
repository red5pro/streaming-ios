#Red5 Pro iOS Streaming Examples

This repository contains a simple project with a number of examples that can be used for testing and reference.  

##Requirements

You will need a functional, running Red5 Pro server web- (or locally-) accessible for the client to connect to.  

For more information visit http://red5pro.com.

##Setup

You will need to modify **/Red5ProStreaming/Supporting Files/connection.plist (the domain value)** to point to your server instance.  If you do not, the examples will not function when you build.

Once you have modified your settings, you can run the application for simulator or device. 

***Note: Publishing does not currently work on simulator!***

##Examples



| [Publishing](https://github.com/red5pro/streaming-ios/tree/master/Red5ProStreaming/Examples/Publish)                 
| :-----
| *Starter example on publishing to a Red5 Pro stream* 
|
| **[Adaptive Bitrate Publishing](https://github.com/red5pro/streaming-ios/tree/master/Red5ProStreaming/Examples/AdaptiveBitratePublish)**
| *Utilize the AdaptiveBitrateController to dynamically adjust video bitrate with connection quality*
|
| **[Subscribing](https://github.com/red5pro/streaming-ios/tree/master/Red5ProStreaming/Examples/Subscribe)**
| *Starter example on subscribing to a Red5 Pro stream*  
|
| **[Stream Send](https://github.com/red5pro/streaming-ios/tree/master/Red5ProStreaming/Examples/StreamSend)**
| *Broadcast messages to subscribers with R5Stream.send*  
|
| **[AutoReconnect](https://github.com/red5pro/streaming-ios/tree/master/Red5ProStreaming/Examples/AutoReconnect)**
| *Wait for a publisher to start by monitoring connection events* 
|
| **[Two Way Video Chat](https://github.com/red5pro/streaming-ios/tree/master/Red5ProStreaming/Examples/TwoWayVideoChat)**
| *Starter example that shows how to implement a two way video chat* 
|
| **[Stream Image Capture](Red5ProStreaming/Examples/StreamImage)**
| *Capture a stream capture of the R5Stream subscriber* 
|
| **[Custom Video Source](Red5ProStreaming/Examples/CustomVideo)**
| *Render custom pixel data to the video stream in place of standard camera input* 
|
| **[Swift Publishing](Red5ProStreaming/Examples/SwiftPublish)**
| *How to publish using Swift* 
|
| **[Clustering](Red5ProStreaming/Examples/Clustering)**
| *How to subscribe to a Red5 Pro Cluster* 
     
##Notes

1. For some of the above examples you will need two devices (a publisher, and a subscriber). You can also use a web browser to subscribe or publish via Flash.
2. You can see a list of active streams by navigating to http://your_red5_pro_server_ip:5080/live/streams.jsp
3. Click on the flash link (for example, flash_publisher) in the streams list displayed to view the published stream in your browser.

