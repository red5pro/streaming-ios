# Published Stream Recording

`R5RecordTypeRecord` signals for the server to record the stream.

### Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[RecordedTest.swift](RecordedTest.swift)***

## Recording

The only difference between this example and the publish test is that in the publish command you send a different RecordType flag:

```Swift
self.publishStream!.publish(Testbed.getParameter("stream1") as! String, type: R5RecordTypeRecord)
```

[RecordedTest.swift #38](RecordedTest.swift#L38)
