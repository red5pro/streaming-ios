# Custom Video Source

This example demonstrates passing custom video data into the R5Stream.

### Example Code

- ***[CustomVideoSource.swift](CustomVideoSource.swift)***
- ***[PublishCustomSourceTest.swift](PublishCustomSourceTest.swift)***

### Setup

To view this example, you simply need to open the example and subscribe to your stream from a second device.  All audio will be recorded, and instead of camera input, a simply plasma style effect is rendered.

### Creating a Custom Video Source

To provide custom video input into an R5Stream the first thing to do is create a custom class that extends R5VideoSource.

To start, a timestamp needs to be setup to pass to the encoder.  Using the `R5VideoSource.FPS` property will let us calculate this timestamp.

```Swift
//setup simple timestamp calculation
self.frameDuration = CMTimeMakeWithSeconds(0.1f, self.fps);
self.PTS = kCMTimeZero;
```

[CustomVideoSource.swift #24](CustomVideoSource.swift#24)

To handle the processing of custom data, you can overwrite `R5VideoSource.startVideoCapture`.  This method is called by the stream when it is ready for video content.  For this example, we will start a simple timer to call `capturePixels` at our desired framerate.

```Swift
override func startVideoCapture() {

	//start a timer to run at desired framerate.
	self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0 / Double(self.fps),
                                                        target: self,
                                                        selector: #selector(capturePixels),
                                                        userInfo: nil,
                                                        repeats: true);
}
```
<sup>
[CustomVideoSource.swift #38](CustomVideoSource.swift#38)
</sup>

Handle the stop of the rendering call in `R5VideoSource.stopVideoCapture`. NOTE: It's important to call the parent's function in this override - that handles closing the encoder.

```Swift
override func stopVideoCapture() {

	//stop the capture!
	self.timer!.invalidate()

  //stop the encoder!
  super.stopVideoCapture()
}
```
<sup>
[CustomVideoSource.swift #48](CustomVideoSource.swift#48)
</sup>

The last thing to do is pass a `CVPixelBufferRef` to the encoder.  `capturePixels:` is called by the timer at the interval specified.

There is some additional math that won't be covered in this example, so it will be skipped over.

The first thing that is needed is an array of bytes that will hold the pixel data.  This example will be using RGB data, so there are 3 bytes per pixel.

```Swift
func capturePixels( time:NSTimer ){

...

let componentsPerPixel = 3;
let rgbPixels: UnsafeMutablePointer<__uint8_t> = UnsafeMutablePointer<__uint8_t>.alloc(Int(frameSize.width * frameSize.height) * componentsPerPixel);
```
<sup>
[CustomVideoSource.swift #54](CustomVideoSource.swift#54)
</sup>

Each pixel can then be assigned a color (between 0-255 in this case) for the RGB channels.

```Swift
//Set the R, G, B channels to the desired color
rgbPixels[(y * bpr) + (componentsPerPixel*x)] = __uint8_t( max( Double(sinf( v * Float(M_PI) )) * Double(UINT8_MAX), 0) );
rgbPixels[(y * bpr) + (componentsPerPixel*x)+1] = __uint8_t( max( Double(cosf( v * Float(M_PI) )) * Double(UINT8_MAX), 0) );
rgbPixels[(y * bpr) + (componentsPerPixel*x)+2] = 0;
```
<sup>
[CustomVideoSource.swift #89](CustomVideoSource.swift#89)
</sup>

Once the bytes have been set to their desired RGB values, we create a `CVPixelBufferRef` that will hold that date for processing.

```Swift
// Create a pixel buffer
var pixelBuffer: CVPixelBuffer?;

//Create a pixel buffer to hold our bytes with RGB format
var result: OSStatus = CVPixelBufferCreateWithBytes(kCFAllocatorDefault,
                                                    Int(frameSize.width),
                                                    Int(frameSize.height),
                                                    kCVPixelFormatType_24RGB,
                                                    rgbPixels,
                                                    Int(frameSize.width) * componentsPerPixel,
                                                    nil,
                                                    &pixelBuffer,
                                                    nil,
                                                    &pixelBuffer);
```
<sup>
[CustomVideoSource.swift #96](CustomVideoSource.swift#96)
</sup>

Next, we can create the buffer information that is needed.  The video format information can be extracted from the pixel buffer, and the only timing information that is required is the timestamp.

```Swift
var videoInfo: CMVideoFormatDescriptionRef?;

//Create a description for the pixel buffer
result = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer!, &videoInfo);

if(result != kCVReturnSuccess) {
	NSLog("Failed to create video info");
}

//Only PTS is needed for the encoder - leave everything else invalid if you want
var timingInfo: CMSampleTimingInfo = kCMTimingInfoInvalid;
timingInfo.duration = kCMTimeInvalid;
timingInfo.decodeTimeStamp = kCMTimeInvalid;
timingInfo.presentationTimeStamp = self.PTS;
```
<sup>
[CustomVideoSource.swift #115](CustomVideoSource.swift#115)
</sup>

Next, we can create our `CMSampleBufferRef` using the `CVPixelBufferRef`, `videoInfo`, and `timingInfo`.

```Swift
var buffer: CMSampleBufferRef?;

//Create the sample buffer for the pixel buffer
result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,
                                            pixelBuffer!,
                                            true, nil, nil,
                                            videoInfo!,
                                            &timingInfo,
                                            &buffer);
```
<sup>
[CustomVideoSource.swift #130](CustomVideoSource.swift#130)
</sup>

The last thing to do is pass the buffer to our encoder, which is part of the `R5VideoSource`, and to increment our timestamp and free up all memory.

```Swift
//push the sample buffer to the encoder with type r5_media_type_video_custom
if(!self.pauseEncoding){
	self.encoder.encodeFrame( buffer, ofType: r5_media_type_video_custom );
}

//increment our timestamp
self.PTS = CMTimeAdd(self.PTS, self.frameDuration);

//free all our content
free(rgbPixels);
```
 <sup>
[CustomVideoSource.swift #140](CustomVideoSource.swift#140)
</sup>


***It is very important to remember to use `r5_media_type_video_custom` to pass this buffer into the encoder.  The standard video format expects a CVImageBufferRef and will fail to encode with custom pixel data!***


This is all that is needed to pass in RGB pixel data in place of the built in camera.  The last thing we have to do is pass this object to the `R5Stream`

```Swift
// Attach the custom source to the stream
let videoSource: CustomVideoSource = CustomVideoSource();
self.publishStream!.attachVideo(videoSource);

```
 <sup>
[PublishCustomSourceTest.swift #31](PublishCustomSourceTest.swift#31)
</sup>
