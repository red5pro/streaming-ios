# Subscribing on Red5 Pro

This example shows you how to interrupt and modify the audio coming from a stream before it reaches the device's speakers.

### Example Code

- ***[SubscribeTest.swift](../SubscribeTest.swift)***
- ***[SubscribeAudioDelayTest.swift](SubscribeAudioDelayTest.swift)***

### Running This Example

Publish to `stream1` from a second device, and then use the `Subscribe - Audio Delay` test. You should notice that the audio has been delayed behind the video by one second.

## Collecting Audio Samples

`R5Stream` has the method `setPlaybackAudioHandler(handlerBlock: ((UnsafeMutablePointer<UInt8>?, Int32, Double) -> Void)` which will provide the raw audio data to the passed block before sending it to the speakers. Its parameters are, in order: a pointer to the C array with the raw data, the number of items in that array, and the timestamp of the audio in milliseconds. In order to keep track of this data while storing it, the `SampleHolder` class was added to hold the appropriate values, as well as an offset to remember where a previous read left off.

```Swift
class SampleHolder: NSObject {
    var sampleData: UnsafeMutablePointer<UInt8>? = nil
    var samples: Int32 = 0
    var offset: Int32 = 0
    var timeStamp: Double = 0.0
}
```

[SubscribeAudioDelayTest.swift #79](SubscribeAudioDelayTest.swift#L79)

To store the data, we first init a new SampleHolder, and then copy the data into the new array - this way the incoming data array can be manipulated later without losing our copy for later. Then the SampleHolder can be added to an instance variable array that will act as a queue.

```Swift
let newSample = SampleHolder.init()
newSample.sampleData = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(samples))
newSample.samples = samples
newSample.timeStamp = timeMillis

newSample.sampleData!.initialize(from: sampleData!, count: Int(samples))

self.sampleBuffer!.append(newSample)
```

[SubscribeAudioDelayTest.swift #27](SubscribeAudioDelayTest.swift#L27)

##Modifying Output
Until we have enough data, the incoming array is zeroed out to turn it into silence. Since this is a pointer to the array that will be used by the system, modifying it will modify the output directly, without needing to explicitly return it. Since the array is made of simple unsigned integers, `UnsafeMutablePointer.initialize(to:count:)` will simply overwrite all the values in the array with the given value. (Similar to `memset` from C)

```Swift
sampleData!.initialize(to: 0, count: Int(samples))
```

[SubscribeAudioDelayTest.swift #59](SubscribeAudioDelayTest.swift#L59)


Once the incoming timestamp passes the appropriate delay amount beyond the timestamp of the first piece of data, we'll need to pass the gathered audio samples instead of silence. Note that each call to this block won't have the same number of samples, meaning that the first SampleHolder stored won't be guaranteed to have all the data requested, and it won't be guaranteed to be completely consumed either. Not passing enough data will cause random drops of silence, while dropping information can cause sharp audio glitches - so once we start passing data, we want to keep passing samples until the output buffer is filled. For this we use UnsafeMutablePointer's `initialize(from:count:)` to copy data into the array (similar to `memcpy` from C) and `advanced(by:)` to get a pointer to an offset part of the array.

```Swift
var samplesPassed: Int32 = 0
while(samplesPassed < samples){
    let pastSample = self.sampleBuffer![0]
    let passing = min(pastSample.samples - pastSample.offset, samples - samplesPassed)
    sampleData!.advanced(by: Int(samplesPassed)).initialize(
        from: pastSample.sampleData!.advanced(by: Int(pastSample.offset)),
        count: Int(passing)
    )
    samplesPassed += passing

    if(pastSample.offset + passing < pastSample.samples){
        pastSample.offset += passing
    }
    else{
        self.sampleBuffer!.removeFirst()
        pastSample.sampleData!.deallocate(capacity: Int(pastSample.samples))
    }
}
```

[SubscribeAudioDelayTest.swift #39](SubscribeAudioDelayTest.swift#L39)

Note that when the entirety of a sample has been written out, the pointer is deallocated before our reference to it is dropped. As we're handling raw memory allocation, this is very important to prevent memory leaks. However, as the system allocated the array coming into the block, that pointer isn't deallocated, as that will cause all sorts of issues. There's good reason why they're called "Unsafe" pointers compared to everything else in Swift.
