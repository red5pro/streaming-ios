# Publish Orientation

`R5Camera.orientation` allows the user to rotate the video source for a stream without interupting the broadcast.

### Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[PublishOrientationTest.swift](PublishOrientationTest.swift)***

## Running the example

Touch the screen at any time while streaming to rotate the video source by 90 degrees. It's sugested that you verify this change with a separate device.

## Using R5Camera.orientation

`R5Camera.orientation` will tell you how much the current video source is rotated from what how it's coming into the application. By getting the instance of R5Camera attached to the R5Stream object and changing its orientation property, this can be modified live for the stream. Once streaming, simply call:

```Swift
let cam = self.publishStream?.getVideoSource() as! R5Camera        
cam.orientation = cam.orientation + 90
```

[PublishOrientationTest.swift #66](PublishOrientationTest.swift#L66)