# Dynamically Swapping a Renderer on playback

This example shows how to dynamically swap in a custom playback renderer while subscribing to a stream.

## Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[SubscribeRendererSwapTest.swift](SubscribeRendererSwapTest.swift)***
- ***[Custom360VideoViewRenderer.swift](../Subscribe360/Custom360VideoViewRenderer.swift)***

# Custom R5VideoViewRenderer

By default, the `R5VideoViewController` has an internal `R5VideoViewRenderer` instance that sends off rendering of decoded video frames to OpenGL.

You can define your own `R5VideoViewRenderer` instance to be used by utilizing the `renderer` mutator of `R5VideoViewController`. Additionally, you can reset the `renderer` before **AND** after already having started playback of a stream; this allows you to dynamically change how the stream is played back based on live information coming from the broadcaster.

As an example: your playback may not know that the broadcaster is using a 360 camera until _after_ already subscribing and getting a notification of camera type. As such, you want to be able to dynamically - while not interrupting the playback - be able to update the rendering functionality of the stream.

Totally possible. In fact, this example demonstrates that!

> Well, in at least that you can dynamically swap in a renderer duing playback...

## Custom360VideoViewRenderer

In this example, we use the `Custom360VideoViewRenderer` created for the [Subscribe360 example](../Subscribe360). There is much more information about the APIs involved in [the documentation for that example](../Subscribe360/README.md), so be sure to check it out.

In short, you can swap in an alternate `R5VideoViewRenderer` instance dynamically, during playback without having to teardown and re-setup the connection!

The example uses a `UIButton` that you tap to invoke the `toggleRenderer` gesture delegate, which then updates the `renderer` property of the `R5VideoViewController` instance:

```swift
@objc func toggleRenderer () {

  if let context = EAGLContext(api: .openGLES3) {

    EAGLContext.setCurrent(context)
    let glView = GLKView.init(frame: self.view.bounds, context: context);
    currentView?.renderer = Custom360VideoViewRenderer(glView: glView)

  }

}
```

[SubscribeRendererSwapTest.swift #50](SubscribeRendererSwapTest.swift#L50)

Doing so will swap in the custom 360 renderer created from the [Subscribe 360 example](../Subscribe360).

> It is important to note that once the `renderer` has been set to a custom renderer created by you - or with our example - the `R5VideoViewController` can not go back to using its internal rendering routines - this includes trying to set it back to the default `R5VideoViewRenderer`.
