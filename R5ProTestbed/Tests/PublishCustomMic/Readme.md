# Custom Microphone Publishing

This example demonstrates passing custom video data into the R5Stream.

### Example Code
- ***[BaseTest.swift](../BaseTest.swift)***
- ***[PublishCustomMicTest.swift](PublishCustomMicTest.swift)***

### Setup

To view this example, you simply need to open the example and subscribe to your stream from a second device.  All video will be recorded, and the microphone audio will have its volume modified before being sent out.

#### Attach a Custom Audio Source

Instead of using an R5Microphone, this example uses a custom video source, the `GainWobbleMic`. This increases and decreases the gain between double volume to muted and back. It does this by extending the R5Microphone class and intercepting the `processData` method.

This method recieves an NSData object of raw audio samples - each byte in it being a single, mono sample - and a timestamp in milliseconds with the 0 point being the start of the stream. The data object is passed by reference, so it needs to be modified in place - by assigning new values to its internal array, and not assiging a object - which would just overwrite the reference.

```Swift
var s: Int
var val: UInt8
let data = samples?.mutableBytes
let length: Int = (samples?.length)!
for i in 0...length {
  val = (data?.advanced(by: i).load(as: UInt8.self))!
  s = Int(Float(val) * self.gain)
  val = UInt8(min(s, Int(UInt8.max)))
  data?.advanced(by: i).storeBytes(of: val, as: UInt8.self)
}
```

[PublishCustomMicTest.swift #74](PublishCustomMicTest.swift#L74)

This example amplifies the value of each byte according to the gain value - clamping the value to keep it from wrapping around when being converted back to a byte. This function could also be used as a timing device to provide completely separate audio.
