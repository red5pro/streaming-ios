# Publish Camera Swap

`R5Camera.device` allows the user to change the video source for a stream without interupting the broadcast.

### Example Code
- ***[BaseTest.swift](../BaseTest.swift)***
- ***[CameraSwapTest.swift](CameraSwapTest.swift)***

## Running the example
Touch the screen at any time while streaming to switch between broadcasting from the front facing and back facing camera.

## Using R5Camera.device
`R5Camera.device` is a reference to the device set in instantiation of the R5Camera object. By getting the instance of R5Camera attached to the R5Stream object and changeing its device property, you can hot-swap sources for the stream. Once streaming, simply call:

```Swift
let camera = self.publishStream?.getVideoSource() as! R5Camera
if(camera.device === frontCamera){
	camera.device = backCamera;
}else{
	camera.device = frontCamera;
}
```

[CameraSwapTest.swift #66](CameraSwapTest.swift#L66)