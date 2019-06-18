# Subscribe To Two Streams

This example demonstrates Subscribing to two different sources at once.

### Example Code

- ***[SubscribeTwoStreams.swift](SubscribeTwoStreams.swift)***
- ***[BaseTest.swift](../BaseTest.swift)***

### Setup

This is intended to be used with two others using the two-way example to put on a presentation, allowing anyone using this client to watch them converse.

### Managing Streams

The special note to be aware of when it comes to handling two streams is that they each need to use a different audio controller. At the moment, the only ones available are `R5AudioControllerModeStandardIO` and `R5AudioControllerModeEchoCancellation`.

```Swift
self.subscribeStream!.audioController = R5AudioController(mode: R5AudioControllerModeStandardIO)
```

[SubscribeTwoStreams.swift #45](SubscribeTwoStreams.swift#L45)

```Swift
self.subscribeStream2?.audioController = R5AudioController(mode: R5AudioControllerModeEchoCancellation)
```

[SubscribeTwoStreams.swift #65](SubscribeTwoStreams.swift#L65)

This means that at this time, iOS can only subscribe to a maximum of two streams, but the process of subscribing to multiple streams is otherwise straightforward.
