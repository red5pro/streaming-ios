# Subscriber With a Metal-Processed View

As of June 2018, Apple has marked OpenGL as deprecated. As the default `R5VideoViewController` uses OpenGL rendering, this means that our suggested display is technically deprecated as well. With how many developers use OpenGL over Apple's proprietary libraries, it's not likely that it will be removed entirely, but for developers who would prefer to avoid as many deprecated systems as possible, the `R5MetalVideoViewController` will provide the same experience without using OpenGL.

### Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[SubscribeMetalViewTest.swift](SubscribeMetalViewTest.swift)***

## Running the example

Begin by publishing to **stream1** from a second device.

There should be no significant difference in performance, and all interfaces available to the `R5VideoViewController` will work the same on the `R5MetalVideoViewController`.

## Backwards Compatability

In the newer versions of iOS, the `R5MetalVideoViewController` will use Metal-powered interfaces. However, those same interfaces used to be powered by OpenGL, so older devices that don't have Metal compatible hardware should still function. However, until Apple decides to completely remove OpenGL, the `R5VideoViewController` is likely to perform better on older devices, and will thus be better for coverage.
