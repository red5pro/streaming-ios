#Adaptive Bitrate Example

You can view the associated code for this example at:
https://github.com/red5pro/streaming-ios/blob/master/AdaptiveBitrateExample


The AdaptiveBitrateController provides a mechanism to dynamically adjust the video publishing bitrate to adjust quality to meet the restrictions of the network connection.

###Setup
The AdaptiveBitrateController is simple to setup.  You simply create a new instance of the controller and attach the stream you wish to control.  It will monitor the stream and make all adjustments automatically for you.

```Objective-C
AdaptiveBitrateController *controller = [AdaptiveBitrateController new];
[controller attachToStream: stream];
```


###Range
The AdaptiveBitrateController will dynamically adjust the video bitrate between the lowest possible bitrate the encoder can encode at, and the value set on the R5VideoSource (typically an R5Camera) on the stream.  The controller will adjust the bitrate ~200 kbps every 2 seconds to achieve the best possible video quality.

Video will be turned off if the stream is unable to maintain a smooth connection at the lowest possible bitrate.  You can force video to be included with the ***AdaptiveBitrateController.requiresVideo*** flag.


###






