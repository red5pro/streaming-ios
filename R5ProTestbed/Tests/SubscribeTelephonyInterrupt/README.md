# Handling Interrupts while Publishing

During an interrupt - such as receiving a phone call - of an application that is publishing a stream, the Operating System may reclaim the media devices used in broadcasting. This means that the Camera and/or Microphone will be disconnected from the broadcast the publishing session halting abruptly - leaving your subscribers wondering what happened.

Though the Red5 Pro SDK cannot stop the Operating System from assuming control in such occurances, we can handle such interruption more gracefully by communicating with subscribers and publishers that interruptions have occurred.

This example - and its paired [PublishTelephonyInterruptTest](../PublishTelephonyInterrupt/PublishTelephonyInterruptTest.swift) test - demonstrate how to handle such interruptions gracefully.

> These examples differ from the [Background](../PublishBackgronud) examples. The **Background Examples** demonstrate how to gracefully handle publishing and subscribing when the application is placed in the background by an explicit User Action - such as hitting the *Home* button. 

## Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[PublishTelephonyInterruptTest.swift](../PublishTelephonyInterrupt/PublishTelephonyInterruptTest.swift)***
- ***[SubscribeTelephonyInterruptTest.swift](SubscribeTelephonyInterruptTest.swift)***

# Running the example

The Publishing example works by listening for interrupt and active notifications to recognize when to stop a broadcast and to alert the Publisher that they can beging the broadcast again after interruption, while also sending out notifications to subscribers about its current status.

The Suscribing example works by responding to Publisher notifications and starting a reconnection loop once it is recognizes that the Publisher's broadcast has been halted.

## Testing

1. Launch the `streaming-ios` app onto two iOS devices.
2. Use one to become the publisher and choose the `Publish - Telephony Interrupt` test to begin a broadcast.
3. On the other device, choose the `Subscribe - Telephony Interrupt` test to begin playback.
4. Interrupt the broadcaster by sending a phone call, FaceTime request, etc.
5. Either accept or decline the interrupt and return to Publisher back to the app.
6. Tap on the Publisher screen to start the broadcast again.

# Publisher

## Responding to Publisher App state

The Publisher responds to notifications to in order to send notifications to subscribers and respond to interrupts:

```Swift
NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: .UIApplicationWillResignActive, object: nil)
NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)}
```

[PublishTelephonyInterruptTest.swift #34](../PublishTelephonyInterrupt/PublishTelephonyInterruptTest.swift#L34)

When the app is resigned from being active, a `tap` gesture is added:

```Swift
@objc func willResignActive(_ notification: Notification) {
    publishStream?.pauseVideo = true

    let streamName = Testbed.getParameter(param: "stream1") as? String
    publishStream?.send("publisherBackground", withParam: "streamName=\(streamName)")
        
    self.tap = UITapGestureRecognizer(target: self, action: #selector(PublishSendTest.handleSingleTap(recognizer:)))
    self.view.addGestureRecognizer(self.tap!)
}
```

[PublishTelephonyInterruptTest.swift #42](../PublishTelephonyInterrupt/PublishTelephonyInterruptTest.swift#L42)

The `tap` gesture will handle re-establishing a broadcast session. However, if the app is returned to the foreground normally - as in the case of hitting the *Home* button once, and then again - then the `tap` gesture handle is removed:

```Swift
@objc func willEnterForeground(_ notification: Notification) {
  publishStream?.pauseVideo = false

  let streamName = Testbed.getParameter(param: "stream1") as? String
  publishStream?.send("publisherForeground", withParam: "streamName=\(streamName)")

  hasReturnedToForeground = true
  if (tap != nil) {
      self.view.removeGestureRecognizer(self.tap!)
      tap = nil
  }
}
```

[PublishTelephonyInterruptTest.swift #52](../PublishTelephonyInterrupt/PublishTelephonyInterruptTest.swift#L52)

If the app has not returned to foreground, and instead has been made active again, the `tap` gesture handle remains - allowing the Publisher to start the broadcast again. Returning to being active without being brought back to the foreground in most cases means that the user (a.k.a., Publisher) was interrupted without the app being put into the background - such as in the case of receiving and declining a phone call.

In the `active` notification response, the broadcast is disconnected as we have most likely lost our media stream due to the interrupt.

```Swift
@objc func didBecomeActive(_ notification: Notification) {
  if (publishStream != nil && !hasReturnedToForeground) {
      let streamName = Testbed.getParameter(param: "stream1") as? String
      publishStream?.send("publisherInterrupt", withParam: "streamName=\(streamName)")
      publishStream?.stop()
  }
  hasReturnedToForeground = false

  if (tap != nil) {
      ALToastView.toast(in: self.view, withText:"Tap to Re-Publish!")
  }
}
```

[PublishTelephonyInterruptTest.swift #65](../PublishTelephonyInterrupt/PublishTelephonyInterruptTest.swift#L65)

Upon tap of the screen from such a state, the stream can be re-published - allowing any subscribers to begin playback of the new stream:

```Swift
func republish () {
  // Set up the configuration
  let config = getConfig()
  // Set up the connection and stream
  let connection = R5Connection(config: config)

  setupPublisher(connection: connection!)
  self.currentView!.attach(publishStream!)
  self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: R5RecordTypeLive)
}
```

[PublishTelephonyInterruptTest.swift #78](../PublishTelephonyInterrupt/PublishTelephonyInterruptTest.swift#L78)

# Subscriber

## Responding to Publisher Notifications

On the Subscriber side, notifications from the Publisher are received to recognize the broadcast state and handle server events appropriately. The `publisherBackground` and `publisherForeground` events are sent from the Publisher using the *Send API*:

```Swift
func publisherBackground(msg: String) {
  NSLog("(publisherBackground) the msg: %@", msg)
  publisherIsInBackground = true
  ALToastView.toast(in: self.view, withText:"Publish Background")
}

func publisherForeground(msg: String) {
  NSLog("(publisherForeground) the msg: %@", msg)
  publisherIsInBackground = false
  ALToastView.toast(in: self.view, withText:"Publisher Foreground")
}
```

[SubscribeTelephonyInterruptTest.swift #61](SubscribeTelephonyInterruptTest.swift#L61)

When a `NetStatus` event notification for `Unpublish` is received and the subscriber is awar of the Publisher having been placed in the background, then it can be determined that an interrupt and disconnect of broadcast has occurred.

At such a state, the Subscriber can begin a reconnect sequence to begin subscribing to the new stream once the Publisher has returned from an interrupt with a new broadcast session:

```Swift
// publisher has unpublished. possibly from background/interrupt.
if (publisherIsInBackground) {
  publisherIsDisconnected = true
  // Begin reconnect sequence...
  let view = currentView
  DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    if(self.subscribeStream != nil) {
        view?.attach(nil)
        self.subscribeStream?.delegate = nil;
        self.subscribeStream!.stop()
    }
    self.reconnect()
  }
}
```

[SubscribeTelephonyInterruptTest.swift #29](SubscribeTelephonyInterruptTest.swift#L29)
