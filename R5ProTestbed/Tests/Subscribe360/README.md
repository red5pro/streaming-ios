# Subscribing to 360 Broadcast

This example shows how to create and define a custom view renderer to playback a broadcast from a 360 Camera.

## Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[Subscribe360Test.swift](Subscribe360Test.swift)***
- ***[Custom360VideoViewRenderer.swift](Custom360VideoViewRenderer.swift)***
- ***[Custom360VideoViewRendererEngine.swift](Custom360VideoViewRendererEngine.swift)***
- ***[Custom360VideoViewCamera.swift](Custom360VideoViewCamera.swift)***

## Assign the Custom360VideoViewRenderer

The [Custom360VideoViewRenderer](Custom360VideoViewRenderer.swift) is assigned as the target renderer for the playback stream, by redefining the `renderer` reference on the `R5VideoViewController` instance:

```swift
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)

  setupDefaultR5VideoViewController()

  if let context = EAGLContext(api: .openGLES3) {

      EAGLContext.setCurrent(context)
      let glView = GLKView.init(frame: self.view.bounds, context: context);
      currentView?.renderer = Custom360VideoViewRenderer(glView: glView)

  }

  let config = getConfig()
  // Set up the connection and stream
  let connection = R5Connection(config: config)
  self.subscribeStream = R5Stream(connection: connection)
  self.subscribeStream!.delegate = self
  self.subscribeStream?.client = self;

  currentView?.attach(subscribeStream)

  // HW Accel required for test.
  self.subscribeStream!.play((Testbed.getParameter(param: "stream1") as! String), withHardwareAcceleration: true)

}
```

[Subscribe360Test.swift #25](Subscribe360Test.swift#L25)

> Note that the `play:withHardwareAcceleration` flag is set to `true` in order to be able to access the `CVPixelBufferRef` from the stream.

## Custom360VideoViewRenderer

The [Custom360VideoViewRenderer](Custom360VideoViewRenderer.swift) is a `R5VideoViewRenderer` extension that overrides the `onDrawFrame` invocation to access the hardware-accelerated decoded `CVPixelBufferRef` video frame from a 360 broadcast and apply transformations for rendering.

It is recommended to request playback with hardware accelerated decoding turned on for a broadcast using a 360 camera. This will move more responsiblity to the GPU to decode what are typically larger size video frames sent at a higher bitrate.

To request hardware accelerated decode for playback, use the `play:withHardwareAcceleration` when requesting playback on the `R5Stream` instance.

```swift
override func onDrawFrame(_ rotation: Int32, andScale scaleMode: r5_scale_mode) {

  super.onDrawFrame(rotation, andScale: scaleMode)

  if let glkView = self.getGLView() {

    if (self.stream != nil && !isRenderering) {

        var projectionMatrix : GLKMatrix4?
        var modelViewMatrix : GLKMatrix4?

        ... matrix operations ...

        isRenderering = true
        if let pb = self.stream?.getPixelBuffer() {
            let buffer = pb.takeUnretainedValue()
            self.engine?.updateTexture(pixelBuffer: buffer)
            self.engine?.render(projectionMatrix: projectionMatrix!, modelViewMatrix: modelViewMatrix!)
        }
        isRenderering = false;

    }

  }
}
```

[Custom360VideoViewRenderer.swift #60](Custom360VideoViewRenderer.swift#L60)

To access the decoded and current video frame in playback as a `CVPixelBufferRef` call `:getPixelBuffer` on the `R5Stream` instance during the `onDrawFrame` invocation.

> The Red5 Pro SDK will handle releasing the `CVPixelBufferRef`. As such, accessing an using an unretained is fine for the purposes of passing the buffer off to the renderer.

## Custom360VideoViewRendererEngine

The [Custom360VideoViewRendererEngine](Custom360VideoViewRendererEngine.swift) is responsible to setting up and using OpenGL for rendering the 360 stream.

The topic of OpenGL and setting up vertex and element buffer objects is too large a topic for this example, however the `CVPixelBufferRef` accessed from the `R5Stream` instance is used to render a **YUV420p** frame which has 2 planes: `Y` (luma) and `UV` (chroma).

The planes are then mapped to 2 textures to be rendered:

```swift
func updateTexture (pixelBuffer: CVPixelBuffer) {

  var result: CVReturn = 0

  if textureCache == nil {
      result = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, context, nil, &textureCache)
      if result != kCVReturnSuccess {
          print("updateTexture: Cache Create failure: ", result)
          return
      }
  }

  if (yTexture != nil) {
      yTexture = nil
  }
  if (uvTexture != nil) {
      uvTexture = nil
  }
  if let textureCache = textureCache {
      CVOpenGLESTextureCacheFlush(textureCache, 0)
  }

  let width = GLsizei(CVPixelBufferGetWidth(pixelBuffer))
  let height = GLsizei(CVPixelBufferGetHeight(pixelBuffer))

  glUseProgram(program)

  glUniform1i(GLint(samplerY), 0)
  glUniform1i(GLint(samplerUV), 1)

  glActiveTexture(GLenum(GL_TEXTURE0))
  result = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                      textureCache!,
                                                      pixelBuffer,
                                                      nil,
                                                      GLenum(GL_TEXTURE_2D),
                                                      GL_LUMINANCE,
                                                      width,
                                                      height,
                                                      GLenum(GL_LUMINANCE),
                                                      GLenum(GL_UNSIGNED_BYTE),
                                                      0,
                                                      &yTexture)

  glBindTexture(CVOpenGLESTextureGetTarget(yTexture!), CVOpenGLESTextureGetName(yTexture!))
  glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
  glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
  glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_CLAMP_TO_EDGE))
  glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_CLAMP_TO_EDGE))

  glActiveTexture(GLenum(GL_TEXTURE1))
  result = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                      textureCache!,
                                                      pixelBuffer,
                                                      nil,
                                                      GLenum(GL_TEXTURE_2D),
                                                      GL_LUMINANCE_ALPHA,
                                                      width / 2,
                                                      height / 2,
                                                      GLenum(GL_LUMINANCE_ALPHA),
                                                      GLenum(GL_UNSIGNED_BYTE),
                                                      1,
                                                      &uvTexture)

  glBindTexture(CVOpenGLESTextureGetTarget(uvTexture!), CVOpenGLESTextureGetName(uvTexture!))
  glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
  glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
  glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_CLAMP_TO_EDGE))
  glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_CLAMP_TO_EDGE))

}
```

[Custom360VideoViewRendererEngine.swift #229](Custom360VideoViewRendererEngine.swift#L229)

The textures are than projected onto a sphere and rendered:

```swift
func render (projectionMatrix: GLKMatrix4, modelViewMatrix: GLKMatrix4) {

  glClearColor(0.1, 0.1, 0.1, 1.0);
  glClear(GLbitfield(GL_COLOR_BUFFER_BIT));

  glUseProgram(program)

  var matrix : GLKMatrix4 = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix)
  withUnsafePointer(to: &matrix) {ptrMatrix in
      ptrMatrix.withMemoryRebound(to: GLfloat.self, capacity: 16) {ptrGLfloat in
          glUniformMatrix4fv(modelViewProjectionMatrix, 1, GLboolean(GL_FALSE), ptrGLfloat)
      }
  }

  glUniform1i(GLint(samplerY), 0)
  glUniform1i(GLint(samplerUV), 1)

  if let yTexture = yTexture,
      let uvTexture = uvTexture {
      glActiveTexture(GLenum(GL_TEXTURE0))
      glBindTexture(CVOpenGLESTextureGetTarget(yTexture), CVOpenGLESTextureGetName(yTexture))

      glActiveTexture(GLenum(GL_TEXTURE1))
      glBindTexture(CVOpenGLESTextureGetTarget(uvTexture), CVOpenGLESTextureGetName(uvTexture))
  }

  glBindVertexArrayOES(vertexArray)
  glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_SHORT), nil)
  glBindVertexArrayOES(0)

}
```

[Custom360VideoViewRendererEngine.swift #301](Custom360VideoViewRendererEngine.swift#L301)

> The model view projection comes from the [Custom360VideoViewCamera](Custom360VideoViewCamera.swift).

## Custom360VideoViewCamera

The [Custom360VideoViewCamera](Custom360VideoViewCamera.swift) is responsible for providing the model view projection used in rendering the textures in a spherical model. It has a default projection, but also responds to user interaction to update the model and projection based on gestures.

### Panning

By placing and moving your finger horizontally and vertically on the device while the 360 stream is being played back, you can change your point of view.

### Zooming

Using a pinching and expanding gesture will manipulate the zoom on the field of view.

### Reset

By tapping on the device screen, you can set the projection back to the default setting.

# Notes On Rendering with Metal

Though this example uses OpenGL routines to render the `CVPixelBufferRef` with a sheprical projection to show the broadcast from a 360 camera, you can alternatively use Apple's [Metal Library](https://developer.apple.com/metal/) to render the stream with access to the `CVPixelBufferRef`.
