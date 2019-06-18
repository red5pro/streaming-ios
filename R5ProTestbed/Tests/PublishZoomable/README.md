# Publishing with live zoom

This example demonstrates the ability to zoom the camera during a live broadcast.

## Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[PublishZoomableTest.swift](PublishZoomableTest.swift)***

# How to zoom

1. Access the `AVCaptureDevice` used in capturing the Camera.
2. Utilize the `ramp` API of `AVCaptureDevice` to assign an animated target zoom value.

# Using the example

A `UISlider` is used to allow users to define the zoom level of the Camera during a live broadcast. Any subscribers will see the zoom in of the Camera live.