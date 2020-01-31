# Subscribe Volume Test

`R5AudioController.setPlaybackGain:` can be used to adjust the playback volume of a stream. The range is from `0.0` to `1.0`.

### Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[SubscribeSetVolumeTest.swift](SubscribeSetVolumeTest.swift)***

## Running the example

1. Begin by publishing to **stream1** from a second device.  **stream1** is the default stream1 name that is used by this example.
2. Use the slider UI to adjust the playback volume of the stream.

## Using setPlaybackGain

`R5AudioController.setPlaybackGain:` takes a value from `0.0` to `1.0`. In this example, the value is changed based on the user input from the slider control.

```swift
let f = self.view.frame
slider = UISlider(frame: CGRect(x:40, y:f.size.height - 40, width:f.size.width - 80, height:20))
slider?.minimumValue = 0
slider?.maximumValue = 100
slider?.isContinuous = true
slider?.tintColor = UIColor.blue
slider?.value = 100
slider?.addTarget(self, action: #selector(sliderValueDidChange(sender:)), for: .valueChanged)
self.view.addSubview(slider!)

@objc func sliderValueDidChange(sender:UISlider!) {
  self.subscribeStream?.audioController.volume = slider!.value / 100
}
```

[SubscribeSetVolumeTest.swift #32](SubscribeSetVolumeTest.swift#L32)

## Note

The volume button mute is locked down by Apple. 

The only solution found for this has been either using the "ambient" playback category - which doesn't allow recording - or switching from `AVAudioSessionCategoryPlayback` category to `AVAudioSessionCategoryPlayAndRecord` within the same session, which messes with AEC (echo cancellation).
