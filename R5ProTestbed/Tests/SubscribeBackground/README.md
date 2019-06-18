# Background Subscribing

The Red5Pro SDK is capable of running in the background, allowing people to multitask without needing to disconnect from their stream.

### Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[SubscribeBackgroundTest.swift](SubscribeBackgroundTest.swift)***

## Running the example

Begin by publishing to **stream1** from a second device.  **stream1** is the default stream1 name that is used by this example.

Note that closing the app won't disconnect the stream - as that's the point of the example. In order to end the stream, either the example needs to be closed by tapping the "Tests" link in the navigation bar at the top of the view, or the app needs to be closed completely by removing it from the active apps list.

## Permissions

By default, when an app loses focus, it's moved into the background only temporarily before being suspended completely. In order to prevent this, the app needs to implement the correct permissions to signify to iOS that it will have more processing to do. This permission can be added in the Capabilities tab of the project editor - specifically the `Background Modes` and its sub permission `Audio`. If editing `info.plist` manually, the `UIBackgroundModes` key needs to be added, with an array that contains the string `audio`.

Note - in general iOS does not permit background graphics processing. Attempts to run video in the background will throw warnings, and after enough warning and app that continues to attempt graphics processes in the background may be forcibly suspended.

## Disabling Graphics Processing

To prevent app culling, the functions `pauseRender` and `resumeRender` have been added to the R5VideoViewController. These need to be called when the app is about to enter the background and when it returns to the foreground, respectively.

The test needs to add observers to be notified of these state changes, preferably in ViewDidAppear with the creation of the subscriber:

```Swift
	NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: .UIApplicationWillResignActive, object: nil)
  NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
}
@objc func willResignActive(_ notification: Notification) {
  currentView?.pauseRender()
}
@objc func willEnterForeground(_ notification: Notification) {
  currentView?.resumeRender()
}
override func closeTest() {
  NotificationCenter.default.removeObserver(self)
  super.closeTest()
```

[SubscribeBackgroundTest.swift #22](SubscribeBackgroundTest.swift#L22)

Also be sure to remove the observers when closing the stream so that the object doesn't continue to listen to events and can be correctly garbage collected.

Note that if you're playing a stream that isn't attached to a view, but can't guarantee that the source won't be pushing any video frames, make sure to call `deactivate_display` function of the R5Stream instead to ensure that incoming video frames are ignored instead of decoded. `pauseRender` calls this automatically, and if the publisher that you're subscribed to hasn't added a video source, this call won't change anything, but otherwise, the fact that frames don't have a view to be pushed to may not stop iOS from culling the app anyway.
The call to undo this if you later add the stream to a view is `activate_display` - which would otherwise be called in `resumeRender`.
