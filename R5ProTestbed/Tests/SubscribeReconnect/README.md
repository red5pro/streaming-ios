# Subscribe Auto Reconnect Test

This example utilizes overriding the `onR5StreamStatus` method to test for and attempt to recover from connection errors by resubscribing after some preconfigured amount of time.

## Example Code

- **_[BaseTest.swift](../BaseTest.swift)_**
- **_[SubscribeAutoReconnectTest.swift](SubscribeAutoReconnectTest.swift)_**

# Implementation

The client responds to events to determine if the stream has closed or fails and attempts to make a re-connection.

## Events & Reconnection

In the occurance of a lost stream from the publisher - either from a network issue or stop of broadcast - you can stop the Subscriber session and start the request cycle again.

There are 2 important events that relate to the loss of a publisher:

1. `ERROR`
2. `NET_STATUS` with message of `NetStream.Play.UnpublishNotify`

The first is an event notification that the stream requested to consume as gone away. The second is an event notification that the publisher has explicitly stopped their broadcast.

By listening on these events and knowing their meaning, you can act accordingly in setting up a new request cycle for the `Streams API`:

```swift
override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {

  super.onR5StreamStatus(stream, withStatus: statusCode, withMessage: msg)

  if(statusCode == Int32(r5_status_connection_close.rawValue)){

    //we can assume it failed here!
    NSLog("Connection closed.")
    self.reconnect()

  }
  else if (statusCode == Int32(r5_status_netstatus.rawValue) && msg == "NetStream.Play.UnpublishNotify") {

    // publisher stopped broadcast. let's resume autoconnect logic.
    let view = currentView
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        if(self.subscribeStream != nil) {
            view?.attach(nil)
            self.subscribeStream!.stop()
            self.subscribeStream = nil
        }
        self.reconnect()
    }
  }

}
```

[SubscribeAutoreconnectTest.java #114](SubscribeAutoreconnectTest.java#L114)
