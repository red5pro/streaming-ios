# Subscriber Bandwidth Test

`onStreamStatus` is a method called by the R5Stream on its assigned `R5StreamDelegate` object. This function allows a developer to gain status information events to monitor the stream.

### Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[SubscriberBandwidthTest.swift](SubscriberBandwidthTest.swift)***

## Running the example

Begin by publishing to **stream1** from a second device.  **stream1** is the default stream1 name that is used by this example.

While streaming, upon receipt of a flag indication that the current net connection has insufficient bandwidth to properly display the stream, the stream view will appear to darken. If it instead receives a flag saying there is enough bandwidth, the screen will return to normal.
To see the effects, the stream should be published in high quality, and the example should be run from a poor network.

## Using onR5StreamStatus

`onR5StreamStatus` is a method of the `R5StreamDelegate` interface. Any object that impliments this interface can be assigned to the `R5Stream.delegate` property of an active stream. In this example, `SubscriberBandwidthTest` is a child of`BaseTest` which impliments `R5StreamDelegate` allowing us to use the object as the delegate for its own stream.

```Swift
self.subscribeStream!.delegate = self
```

[SubscriberBandwidthTest.swift #29](SubscriberBandwidthTest.swift#L29)

In order to add functionality, the `onR5StreamStatus` function from `Base Test` needs to be overridden. This overridden function can then parse the message sent to it to determine what action, if any, needs to be taken.

```Swift
override func onR5StreamStatus(stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {

  super.onR5StreamStatus( stream, withStatus: statusCode, withMessage: msg)

  if(statusCode == Int32(r5_status_netstatus.rawValue)){
    if(msg == "NetStream.Play.SufficientBW"){
            //If the message sent to this function indicates Sufficient Bandwidth, make the black overlay comeletely transparent    

      overlay!.layer.opacity = 0.0
    }else if(msg == "NetStream.Play.InSufficientBW"){
            //If the message sent to this function indicates Sufficient Bandwidth, make the black overlay half visible, visually dimming the screen.
      overlay!.layer.opacity = 0.5
    }
  }

}
```

[SubscriberBandwidthTest.swift #49](SubscriberBandwidthTest.swift#L49)