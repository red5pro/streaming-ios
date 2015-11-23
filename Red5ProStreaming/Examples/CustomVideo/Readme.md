#Custom Video Source

This example demonstrates passing custom video data into the R5Stream.

###Example Code
- ***[CustomVideoSourceExample.mm](
CustomVideoSourceExample.mm)***

###Setup
To view this example, you simply need to open the example and subscribe to your stream from a second device.  All audio will be recorded, and instead of camera input, a simply plasma style effect is rendered.

###Creating a Custom Video Source
To provide custom video input into an R5Stream the first thing to do is create a custom class that extends R5VideoSource.

To start, a timestamp needs to be setup to pass to the encoder.  Using the `R5VideoSource.FPS` property will let us calculate this timestamp.

```
//setup simple timestamp calculation
self.frameDuration = CMTimeMakeWithSeconds(0.1f, self.fps);
self.PTS = kCMTimeZero;
```
<sup>
[ColorsVideoSource.mm #24](ColorsVideoSource.mm#24)
</sup>

To handle the processing of custom data, you can overwrite `R5VideoSource.startVideoCapture`.  This method is called by the stream when it is ready for video content.  For this example, we will start a simple timer to call `capturePixels` at our desired framerate.

```
-(void)startVideoCapture{
    
//start a timer to run at desired framerate.
self.timer = [NSTimer scheduledTimerWithTimeInterval:
				1.0f/self.fps
				target:self 
				selector:@selector(capturePixels:)
				userInfo:nil
				repeats:YES];
    
}

```
<sup>
[ColorsVideoSource.mm #33](ColorsVideoSource.mm#33)
</sup>

Handle the stop of the rendering call also be handled in `R5VideoSource.stopVideoCapture`.

```
-(void)stopVideoCapture{
    
    //stop the capture!
    [self.timer invalidate];
    
}
```
<sup>
[ColorsVideoSource.mm #45](ColorsVideoSource.mm#45)
</sup>

The last thing to do is pass a `CVPixelBufferRef` to the encoder.  `capturePixels:` is called by the timer at the interval specified.

There is some additional math that won't be covered in this example, so it will be skipped over.

The first thing that is needed is an array of bytes that will hold the pixel data.  This example will be using RGB data, so there are 3 bytes per pixel.

```
-(void)capturePixels:(NSTimer *)timer{

...

int componentsPerPixel = 3;
        
uint8_t *rgbpixels = (uint8_t*)malloc(frameSize.width*frameSize.height*componentsPerPixel);
```
 <sup>
[ColorsVideoSource.mm #53](ColorsVideoSource.mm#53)
</sup>

Each pixel can then be assigned a color (between 0-255 in this case) for the RGB channels.

```
//Set the R, G, B channels to the desired color
rgbpixels[(y * bpr)+x]   = sinf(v*M_PI) * UINT8_MAX;
rgbpixels[(y * bpr)+x+1] = cosf(v*M_PI)* UINT8_MAX ;
rgbpixels[(y * bpr)+x+2] = 0;
```
 <sup>
[ColorsVideoSource.mm #91](ColorsVideoSource.mm#91)
</sup>

Once the bytes have been set to their desired RGB values, we create a `CVPixelBufferRef` that will hold that date for processing.

```
 // Create a pixel buffer
CVPixelBufferRef pixelBuffer = NULL;
        
//Create a pixel buffer to hold our bytes with RGB format
OSStatus result =  CVPixelBufferCreateWithBytes(
		kCFAllocatorDefault,
		frameSize.width,
		frameSize.height,
		kCVPixelFormatType_24RGB,
		rgbpixels,
		frameSize.width * (componentsPerPixel),
		NULL,
		(void*)pixelBuffer,
		NULL,
		&pixelBuffer);
```
 <sup>
[ColorsVideoSource.mm #100](ColorsVideoSource.mm#100)
</sup>

Next, we can create the buffer information that is needed.  The video format information can be extracted from the pixel buffer, and the only timing information that is required is the timestamp.

```
CMVideoFormatDescriptionRef videoInfo = NULL;
        
//Create a description for the pixel buffer
result = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &videoInfo);
        
if(result != kCVReturnSuccess)
    NSLog(@"Failed to create video info");
        
//Only PTS is needed for the encoder - leave everything else invalid if you want
CMSampleTimingInfo timingInfo = kCMTimingInfoInvalid;
        timingInfo.duration = kCMTimeInvalid;
        timingInfo.decodeTimeStamp = kCMTimeInvalid;
        timingInfo.presentationTimeStamp = self.PTS;
```
 <sup>
[ColorsVideoSource.mm #112](ColorsVideoSource.mm#112)
</sup>

Next, we can create our `CMSampleBufferRef` using the `CVPixelBufferRef`, `videoInfo`, and `timingInfo`.

```
CMSampleBufferRef buffer = NULL;
        
//Create the sample buffer for the pixel buffer!
result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,
	pixelBuffer,
	true,
	NULL,
	NULL,                                          	videoInfo,                                        	&timingInfo,                                                 	&buffer);
```
 <sup>
[ColorsVideoSource.mm #127](ColorsVideoSource.mm#127)
</sup>

The last thing to do is pass the buffer to our encoder, which is part of the `R5VideoSource`, and to increment our timestamp and free up all memory.

```
 //push the sample buffer to the encoder with type r5_media_type_video_custom
if(!self.pauseEncoding)
		[self.encoder encodeFrame:buffer 	
		ofType:r5_media_type_video_custom];
            
//increment our timestamp!
self.PTS = CMTimeAdd(self.PTS, self.frameDuration);

//free all our content!
CFRelease(buffer);
CFRelease(pixelBuffer);
free(rgbpixels);

}
```
 <sup>
[ColorsVideoSource.mm #137](ColorsVideoSource.mm#137)
</sup>


***It is very important to remember to use `r5_media_type_video_custom` to pass this buffer into the encoder.  The standard video format expects a CVImageBufferRef and will fail to encode with custom pixel data!***


This is all that is needed to pass in RGB pixel data in place of the built in camera.  The last thing we have to do is pass this object to the `R5Stream`

```
//create a new video source which will pump video to the stream
    ColorsVideoSource *customVideoSource = [ColorsVideoSource new];
    
[self.publish attachVideo:customVideoSource];

```
 <sup>
[CustomVideoSourceExample.m #42](CustomVideoSourceExample.m#42)
</sup>