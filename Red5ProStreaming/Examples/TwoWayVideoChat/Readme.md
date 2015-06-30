#Two Way Video Chat

This example demonstrates two way communication using Red5 Pro.  It also demonstrates using Remote Procedure Calls (RPC) on the server.

###Example Code
- ***[TwoWayVideoChatExample.m](/TwoWayVideoChatExample.m)***

- ***[BaseExample.m](
https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/BaseExample.m)***

###Setup
Two way communication simply requires setting up a publish stream and a subscribe stream at the same time.

To start, a publisher is setup and 


```Objective-C
R5AdaptiveBitrateController *adaptor = [R5AdaptiveBitrateController new];
[adaptor attachToStream:self.publish];
```

<sup>
[AdaptiveBitrateExample.mm #29](https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/Examples/AdaptiveBitratePublish/AdaptiveBitrateExample.mm#L29)
</sup>

The controller will continuously adjust the video bitrate until the stream has closed.

###Range
The AdaptiveBitrateController will dynamically adjust the video bitrate between the lowest possible bitrate the encoder can encode at, and the value set on the R5VideoSource (typically an R5Camera) on the stream.  

```[self.publish getVideoSource].bitrate = 768;
```

<sup>
[AdaptiveBitrateExample.mm #24](https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/Examples/AdaptiveBitratePublish/AdaptiveBitrateExample.mm#L24)
</sup>


The controller will adjust the bitrate ~200 kbps every 2 seconds to achieve the best possible video quality.



Video will be turned off if the stream is unable to maintain a smooth connection at the lowest possible bitrate.  You can force video to be included with the `AdaptiveBitrateController.requiresVideo` flag.






