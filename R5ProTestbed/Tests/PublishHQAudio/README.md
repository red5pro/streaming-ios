# Publishing High Quality Audio

`R5Microphone.sampleRate` allows the user to increase the number of times per second that a device grabs a signal from the microphone. Higher values can improve the quality of a broadcast.

### Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[PublishHQAudioTest.swift](PublishHQAudioTest.swift)***

## Using R5Microphone.sampleRate

`R5Microphone.sampleRate` is by default set to 16000 - or 16khz, which is more than enough for most applications, but far from archival quality, especially when it comes to music. Note that setting this value higher will also require a higher bitrate. Increasing the bitrate without increasing the sample rate will only get you so far in reducing compression on the audio, but increasing the sample rate without increasing the bitrate will increase how much each sample is compressed, which could lead to a worse sound.

```Swift
self.publishStream?.getMicrophone().sampleRate = 44100//hz (samples/second)
self.publishStream?.getMicrophone().bitrate = 128//kbps
```

[PublishHQAudioTest.swift #37](PublishHQAudioTest.swift#L37)

 This must be set before you start publishing, and changing the value after calling `R5Stream.publish` will not effect the sample rate.

## Receiving HQ Audio

iOS will default to 16khz for playback as well. In order to receive high quality audio, the playback settings, you need to set it to the same value like so:
 `R5AudioController.sharedInstance().playbackSampleRate = 44100`
 Again, this needs to be set before calling `R5Stream.play`

## Two Way and HQ Audio

Two way applications require echo cancellation to minimize feedback, and in order for the device to cancel playback that's received by the microphone, the two signals need to meet certain settings. In order for it to work correctly, the sample rates of the publisher and subscriber should be the same, but we also recommend setting them to 16khz, as this is what we've found to work most consistently.
