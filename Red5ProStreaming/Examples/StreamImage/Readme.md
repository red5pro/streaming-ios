#Stream Image Capture

`R5Stream.getStreamImage` allows the user to capture a screenshot of the stream at any time.  

###Example Code
- ***[StreamImageExample.m](/StreamImageExample.m)***

- ***[BaseExample.m](
https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/BaseExample.m)***

##Running the example
Begin by publishing to **stream1** from a second device.  **stream1** is the default stream1 name that is used by this example. Select the **StreamImage** option to open a subscriber view. 

Touch the screen at any time while streaming to popup a temporary overlay containing the UIImage that is returned from the Red5 Pro SDK.

##Using getStreamImage
`R5Stream.getStreamImage` returns a UIImage containing a screenshot of the current stream.  The image dimensions match the incoming stream dimensions, and contain RGB data.  Once streaming, simply call:

```
//Get a UI Image with the current frame
UIImage *img = [self.subscribe getStreamImage];
```
<sup>
[StreamImageExample.m #41](/StreamImageExample.m#L41)
</sup>

The UIImage can be saved to disk, displayed with a UIImageView, or processed in any way that is needed.