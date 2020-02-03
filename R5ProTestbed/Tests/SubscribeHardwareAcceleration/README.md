# Subscribing to playback with Hardware Accelerated Video Decode

This example shows how to playback a stream using the Hardware Accelerated decode of the video data.

## Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[SubscribeHardwareAccelerationTest.swift](SubscribeHardwareAccelerationTest.swift)***

# Video Decoding

In Mobile SDK versions prior to `6.0.0`, the SDK defaulted to decoding incoming video frames on the CPU using an RGB scalar. The default for `6.0.0` and forward is to move the video decode operation to the GPU. This generates YUV420p (tri-planar) data.

Additionally, you can request to use **hardware accelerated** decode capabilities of the target platform; in the case of iOS, that is `VideoToolbox`. The result of using **hardware acceleration** for decode is the generation of a YUV420v data represented as a `CVPixelBufferRef`.

## play:withHardwareAcceleration

The API to turn on hardware accelerated video frame decoding is `play:withHardwareAcceleration`:

```swift
self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String, withHardwareAcceleration: true)
```

[SubscribeHardwareAccelerationTest #57](SubscribeHardwareAccelerationTest.swift#L57)

## setFrameListener

Because there are a few different possibilities in requesting decode format as of the `6.0.0` release, the `setFrameListener` callback API of `R5Stream` has been updated to include the format and size of the data being sent.

```swift
// Example of using a frame listener to access the YUV420v (CVPixelBufferRef) data.
self.subscribeStream?.setFrameListener({data, format, size, width, height in
  let f = Int(format.rawValue)                        // YUV420v = 3
  let s =  String(format: "Video Format: (%d)", f)    // Video Format: (3)
})
```

[SubscribeHardwareAccelerationTest #27](SubscribeHardwareAccelerationTest.swift#L27)

The `r5_stream_format` enumeration is:

* `r5_stream_format_unknown` : an unknown/unspecified format
* `r5_stream_format_rgb` : RGB. The `data` argument is a single block of data.
* `r5_stream_format_yuv_planar` : YUV420p, tri-planar. The `data` is an array of data in 3 planes (Y, U, V, respectively).
* `r5_stream_format_yuv_biplanar` : YUV420v. The `data` argument is a `CVPixelBufferRef`.

# Note On Custom Rendering

By default, the Mobile SDKs push the decoded video data to be rendered on an OpenGL surface. The SDKs recognize the different formats and push to render routines accordingly.

As an alternative, the Mobile SDKs also provide an API to override this default rendering and allow you to take control. This is particularly advantageous when using hardware accelerated decode.

Within this testbed we have provided an example of using hardware accelerated decode and custom rendering to playback a broadcast from a 360 camera: [Subscribe 360 Example](../Subscribe360). Enjoy!
