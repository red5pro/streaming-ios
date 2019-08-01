# Publish Mute/Unmute

The `R5Stream:pauseAudio` and `R5Stream:pauseVideo` mutable properties allow for a broadcast stream to be muted and unmuted of audio and video separately.

### Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[PublishPauseTest.swift](PublishPauseTest.swift)***

## Running the example

The `PublishPauseTest` launches in a broadcast session with Audio & Video inputs enabled and streaming.

Touch the screen at any time while streaming to toggle between muted and unmuted states of each Audio and Video input. Subscribe to the stream on another device to see how the muted states affect the broadcast.

The toggle sequence is as follows when you tap the screen multiple times:

1. The first tap will mute the audio being sent.
2. The second tap will unmute the audio from _Tap 1_ and mute the video.
3. The third tap will mute the audio again - muting both video and audio at the same time.
4. The fourth tap will unmute both audio and video, returning to its original state on launch of test and broadcast.

## Using RStream:pauseAudio and R5Stream:pauseVideo

`R5Stream:pauseAudio` and `R5Stream:pauseVideo` are mutable properties that can be set to the desired boolean value:

* `true` will mute the media in real time (during a live broadcast).
* `false` will unmute the media in real time (during a live broadcast).

```swift
func handleSingleTap(_ recognizer : UITapGestureRecognizer) {

    let hasAudio = !(self.publishStream?.pauseAudio)!;
    let hasVideo = !(self.publishStream?.pauseVideo)!;

    if (hasAudio && hasVideo) {
        self.publishStream?.pauseAudio = true
        self.publishStream?.pauseVideo = false
        ALToastView.toast(in: self.view, withText:"Pausing Audio")
    }
    else if (hasVideo && !hasAudio) {
        self.publishStream?.pauseVideo = true
        self.publishStream?.pauseAudio = false
        ALToastView.toast(in: self.view, withText:"Pausing Video")
    }
    else if (!hasVideo && hasAudio) {
        self.publishStream?.pauseVideo = true
        self.publishStream?.pauseAudio = true
        ALToastView.toast(in: self.view, withText:"Pausing Audio/Video")
    }
    else {
        self.publishStream?.pauseVideo = false
        self.publishStream?.pauseAudio = false
        ALToastView.toast(in: self.view, withText:"Resuming Audio/Video")
    }

}
```

[PublishPauseTest.swift #49](PublishPauseTest.swift#L49)

## Listening for mute on a Subscriber stream

Setting the `R5Stream:pauseAudio` and `R5Stream:pauseVideo` attribute value on a broadcast stream change the `streamingMode` value of the metadata that is additionally broadcast to subscribers of the stream. As a subscriber, you can listen for their respective mute and unmute states of a broadcast stream from the status codes defined for [R5StreamDelegate:onR5StreamStatus](https://www.red5pro.com/docs/static/ios-streaming/protocol_r5_stream_delegate-p.html).
