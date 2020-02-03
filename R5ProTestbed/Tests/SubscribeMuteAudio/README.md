# Subscribe Mute Test

`R5AudioController.setPlaybackGain:` can be used to adjust the playback volume of a stream. The range is from `0.0` to `1.0`.

### Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[SubscribeMuteTest.swift](SubscribeMuteTest.swift)***

## Running the example

Begin by publishing to **stream1** from a second device.  **stream1** is the default stream1 name that is used by this example.

Touch the screen at any time while streaming to toggle mute of audio in playback.

## Using setPlaybackGain

`R5AudioController.setPlaybackGain:` takes a value from `0.0` to `1.0`. In this example, the value is toggled between `0.0` and `1.0` to mute and set full volume, respectively.

```swift
isMuted = !isMuted
self.subscribeStream?.audioController.volume = isMuted ? 0 : 1
```

[SubscribeMuteTest.swift #53](SubscribeMuteTest.swift#L53)

## Note

The volume button mute is locked down by Apple. 

The only solution found for this has been either using the "ambient" playback category - which doesn't allow recording - or switching from `AVAudioSessionCategoryPlayback` category to `AVAudioSessionCategoryPlayAndRecord` within the same session, which messes with AEC (echo cancellation).
