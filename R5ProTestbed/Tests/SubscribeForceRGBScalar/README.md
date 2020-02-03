# Subscribing to playback with RGB decode

This example shows how to playback a stream using the CPU decode of video frames to RGB.

## Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[SubscribeForceRGBScalarTest.swift](SubscribeForceRGBScalarTest.swift)***

# Video Decoding

In Mobile SDK versions prior to `6.0.0`, the SDK defaulted to decoding incoming video frames on the CPU using an RGB scalar. There were other API from the SDK that related to accessing these frames that you may have been using in your project(s). As such, providing an API to request to decode to RGB and access that RGB data is preserved for backward-compatiblity.

As of the `6.0.0` release of the Mobile SDKs, video decoding has been moved to the GPU to provide better playback. By default, the video frames are now decoded to YUV420v which is 3 planes of frame data.

Additionally, you can request to use hardware accelerated decode of the platform. In the case of iOS, that uses `VideoToolbox` and produces a YUV420p frame represented as a `CVPixelBufferRef`.

> For **Hardware Acceleration** usage, see [SubscribeHardwareAcceleration](../SubscribeHardwareAcceleration).

## play:withForcedRGBScalar

The API to support backward compatibility in generating and accessing the RGB video frame is `play:withForcedRGBScalar`:

```swift
self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String, withForcedRGBScalar: true)
```

[SubscribeForceRGBScalarTest #30](SubscribeForceRGBScalarTest.swift#L30)

> The `R5Stream` API of `play` (which previously would produce RGB frame data) now defaults to offloading the video decode to the GPU to generate YUV420p (tri-planar) data.

## setFrameListener

Because there are a few different possibilities in requesting decode format as of the `6.0.0` release, the `setFrameListener` callback API of `R5Stream` has been updated to include the format and size of the data being sent.

```swift
// Example of using a frame listener to access the RGB data.
self.subscribeStream?.setFrameListener({data, format, size, width, height in
  let f = Int(format.rawValue)                        // RGB = 1
  let s =  String(format: "Video Format: (%d)", f)    // Video Format: (1)
})
```

[SubscribeForceRGBScalarTest #46](SubscribeForceRGBScalarTest.swift#L46)

The `r5_stream_format` enumeration is:

* `r5_stream_format_unknown` : an unknown/unspecified format
* `r5_stream_format_rgb` : RGB. The `data` argument is a single block of data.
* `r5_stream_format_yuv_planar` : YUV420p, tri-planar. The `data` is an array of data in 3 planes (Y, U, V, respectively).
* `r5_stream_format_yuv_biplanar` : YUV420v. The `data` argument is a `CVPixelBufferRef`.
