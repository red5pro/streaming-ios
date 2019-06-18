# Background Publishing

The Red5Pro SDK is capable of running in the background, allowing people to multitask without needing to disconnect from their stream.

### Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[PublishBackgroundTest.swift](PublishBackgroundTest.swift)***

## Running the example

Note that closing the app won't disconnect the stream - as that's the point of the example. In order to end the stream, either the example needs to be closed by tapping the "Tests" link in the navigation bar at the top of the view, or the app needs to be closed completely by removing it from the active apps list.

## Permissions

By default, when an app loses focus, it's moved into the background only temporarily before being suspended completely. In order to prevent this, the app needs to implement the correct permissions to signify to iOS that it will have more processing to do. This permission can be added in the Capabilities tab of the project editor - specifically the `Background Modes` and its sub permission `Audio`. If editing `info.plist` manually, the `UIBackgroundModes` key needs to be added, with an array that contains the string `audio`.

Note - in general iOS does not permit background graphics processing. Attempts to run video in the background will throw warnings, and after enough warning and app that continues to attempt graphics processes in the background may be forcibly suspended.

## Disabling Graphics Processing

iOS doesn't send data from the camera to background apps, so most of the work in preventing app culling is done for you. Do note that if you're using a custom video source, you'll need to disable it explicitly. To continue sending audio data without interruption from suddenly having no audio data, the R5Stream property `pauseVideo` needs to be set to true when the app is about to enter the background, and then set to false when it returns to the foreground to continue handling video.

The test needs to add observers to be notified of these state changes, preferably in ViewDidAppear with the creation of the subscriber:

```Swift
	NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: .UIApplicationWillResignActive, object: nil)
  NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
}
@objc func willResignActive(_ notification: Notification) {
  publishStream?.pauseVideo = true
}
@objc func willEnterForeground(_ notification: Notification) {
  publishStream?.pauseVideo = false
}
override func closeTest() {
  NotificationCenter.default.removeObserver(self)
  super.closeTest()
```

[SubscribeBackgroundTest.swift #22](SubscribeBackgroundTest.swift#L22)

Also be sure to remove the observers when closing the stream so that the object doesn't continue to listen to events and can be correctly garbage collected.
