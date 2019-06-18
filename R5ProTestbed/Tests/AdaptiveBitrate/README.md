# Adaptive Bitrate Publishing

This example demonstrates the AdaptiveBitrateController, which provides a mechanism to dynamically adjust the video publishing bitrate to adjust quality to meet the bandwidth restrictions of the network connection or encoding hardware.

### Example Code
- ***[BaseTest.swift](../BaseTest.swift)***
- ***[AdaptiveBitrateControllerTest.swift](AdaptiveBitrateControllerTest.swift)***

### Setup
The AdaptiveBitrateController is easy to set up.  You simply create a new instance of the controller and attach the stream you wish to control.  It will monitor the stream and make all adjustments automatically for you.


```Swift
let controller = R5AdaptiveBitrateController()
controller.attachToStream(self.publishStream!)
```

[AdaptiveBitrateExample.swift #32](AdaptiveBitrateControllerTest.swift#L32)

The controller will continuously adjust the video bitrate until the stream has closed.

### Range
The AdaptiveBitrateController will dynamically adjust the video bitrate between the lowest possible bitrate the encoder can encode at, and the value set on the R5VideoSource (typically an R5Camera) on the stream. In this case, the value is assigned in the base class according to the value in tests.plist 

```Swift
let camera = R5Camera(device: videoDevice, andBitRate: Int32(Testbed.getParameter("bitrate") as! Int))
```

[BaseTest.swift #85](../BaseTest.swift#L85)

The controller will adjust the bitrate ~200 kbps every 2 seconds to achieve the best possible video quality.

Video will be turned off if the stream is unable to maintain a smooth connection at the lowest possible bitrate.  You can force video to be included with the `AdaptiveBitrateController.requiresVideo` flag.