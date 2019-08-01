# Subscribing with AV Session Management

This example demonstrates manually controlling iOS's audio session, instead of letting the `R5AudioController` handle it. This allows you to play sounds without being interrupted by the Red5Pro SDK opening and closing the session around the stream.

### Example Code
- ***[BaseTest.swift](../BaseTest.swift)***
- ***[SubscribeAVCategoryTest.swift](SubscribeAVCategoryTest.swift)***

### Setup
In order to signal to the `R5AudioController` that it shouldn't handle the `AVAudioSession` all you need to do is set the `inheritAVSessionOptions` of the R5Configuration to false. This way, it won't use the Red5Pro default audio options, and will instead trust that the session is already open.


```Swift
let config = getConfig()
config.inheritAVSessionOptions = false
```

[SubscribeAVCategoryTest.swift #29](SubscribeAVCategoryTest.swift#L29)

