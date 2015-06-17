#Adaptive Bitrate Publishing

This example demonstrates the AdaptiveBitrateController, which provides a mechanism to dynamically adjust the video publishing bitrate to adjust quality to meet the bandwidth restrictions of the network connection or encoding hardware.

###Example Code
- ***[AdaptiveBitrateExample.mm](
https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/Examples/AdaptiveBitratePublish/AdaptiveBitrateExample.mm)***

- ***[BaseExample.m](
https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/BaseExample.m)***

###Setup
The AdaptiveBitrateController is simple to setup.  You simply create a new instance of the controller and attach the stream you wish to control.  It will monitor the stream and make all adjustments automatically for you.


```Objective-C
R5AdaptiveBitrateController *adaptor = [R5AdaptiveBitrateController new];
[adaptor attachToStream:self.publish];
```
<sup>
[AdaptiveBitrateExample.mm #29](https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/Examples/AdaptiveBitratePublish/AdaptiveBitrateExample.mm#L29)
</sup>

The controller will continuously adjust the video bitrate until the stream has closed.

###Range
The AdaptiveBitrateController will dynamically adjust the video bitrate between the lowest possible bitrate the encoder can encode at, and the value set on the R5VideoSource (typically an R5Camera) on the stream.  The controller will adjust the bitrate ~200 kbps every 2 seconds to achieve the best possible video quality.

Video will be turned off if the stream is unable to maintain a smooth connection at the lowest possible bitrate.  You can force video to be included with the `AdaptiveBitrateController.requiresVideo` flag.







