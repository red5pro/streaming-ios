# Shared Object Streamless Test

This example builds off the [SharedObject](../SharedObject) example, yet, instead of relying on establishing a connection to a Shared Object based on a previously established RTSP connection through a Stream, it utilizes the `startDataOnlyStream` method of the `R5Connection` instance to connect to a Shared Object without a Stream:

```swift
let config = getConfig()
// Set up the connection and stream
connection = R5Connection(config: config)
connection?.delegate = self
connection?.client = self

sendBtn?.isEnabled = false
connection?.startDataOnlyStream()
```

> Please refer to the [SharedObject](../SharedObject) example for using the Shared Object API for connection and method and property handling.
