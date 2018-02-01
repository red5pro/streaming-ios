#Publish Local Record

`R5Stream.record` captures a local copy of a stream to the device's camera roll.

###Example Code
- ***[BaseTest.swift](../BaseTest.swift)***
- ***[PublishTest.swift](../Publish/PublishTest.swift)***
- ***[PublishLocalRecordTest.swift](PublishLocalRecordTest.swift)***

##Running the example
Open the example, and the app will begin streaming and recording. Close the app to end both, and then open the Photos app to see your newly recorded content.

##Using R5Stream.record
`R5Stream.record` triggers the SDK to begin passing data from the camera and microphone - if they are attached - to a file writer. Once the stream has ended, the created file will be passed to the phone's camera roll. Once streaming, simply call:

```Swift
self.publishStream!.record(withName: "fileTest")
```
<sub>
[PublishLocalRecordTest.swift #18](PublishLocalRecordTest.swift#L18)
</sub>

To end the recording before ending the stream, simply call `R5Stream.endLocalRecord`
