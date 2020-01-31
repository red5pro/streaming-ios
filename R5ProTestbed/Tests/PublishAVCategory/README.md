# Publishing with AV Session Management

This example demonstrates manually controlling iOS's audio session, instead of letting the `R5AudioController` handle it. This allows you to play sounds without being interrupted by the Red5Pro SDK opening and closing the session around the stream.

### Example Code
- ***[BaseTest.swift](../BaseTest.swift)***
- ***[PublishAVCategoryTest.swift](PublishAVCategoryTest.swift)***

### Setup
In order to signal to the `R5AudioController` that it shouldn't handle the `AVAudioSession` all you need to do is set the `inheritAVSessionOptions` of the R5Configuration to false. This way, it won't use the Red5Pro default audio options, and will instead trust that the session is already open.


```swift
let config = getConfig()
config.inheritAVSessionOptions = false
let session : AVAudioSession = AVAudioSession.sharedInstance()
do {
    let optionVal = AVAudioSession.CategoryOptions(rawValue: AVAudioSession.CategoryOptions.RawValue(UInt8(AVAudioSession.CategoryOptions.mixWithOthers.rawValue) | UInt8(AVAudioSession.CategoryOptions.allowBluetooth.rawValue) | UInt8(AVAudioSession.CategoryOptions.defaultToSpeaker.rawValue)))

    if #available(iOS 10.0, *) {
        try session.setCategory(AVAudioSession.Category.playAndRecord, mode:.default, options: optionVal)
    } else {
        // Fallback on earlier versions
        // This would require session.setCategory(_:) or session.setCategory(_:options:) which are available to iOS6+
        // However, neither are available in Swift 4, and so either require a bridge through Objective C
        try AVAudioSessionSuplement.setCategory(session, category:.playAndRecord, options: optionVal)
    }

    try session.setActive(true)

}
catch let error as NSError {
    NSLog(error.localizedFailureReason!)
}
```

[PublishAVCategoryTest.swift #27](PublishAVCategoryTest.swift#L27)

