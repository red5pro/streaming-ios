# Publish Local Record

`R5Stream.record` captures a local copy of a stream to the device's camera roll.

### Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[PublishTest.swift](../Publish/PublishTest.swift)***
- ***[PublishLocalRecordTest.swift](PublishLocalRecordTest.swift)***

## Running the example

Open the example, and the app will begin streaming and recording. Close the app to end both, and then open the Photos app to see your newly recorded content.

## Using R5Stream.record

`R5Stream.record` triggers the SDK to begin passing data from the camera and microphone - if they are attached - to a file writer. Once the stream has ended, the created file will be passed to the phone's camera roll. Once streaming, simply call:

```Swift
self.publishStream!.record(withName: "fileTest")
```

To end the recording before ending the stream, simply call `R5Stream.endLocalRecord`

## Record Quality

There is a second `record` function that takes a dictionary object so that the recording doesn't need to use the same settings as the broadcast - which can be especially important if the broadcast needs to transmit over a poor network. Unfortunately video size, frame rate, and audio sample rate are determined at capture, but bitrate for audio and video can both be set at the encoder. Passing a dictionary to `R5Stream.record(withName,withProps)` with a number for the `R5RecordVideoBitRateKey` or `R5RecordAudioBitRateKey` or both, will set that value for recording, separate from the associated values for the stream.

```Swift
let vidRate = (Testbed.getParameter(param: "bitrate") as! Int)*2
let props = [R5RecordVideoBitRateKey: vidRate, R5RecordAudioBitRateKey: 32]

self.publishStream!.record(withName: "fileTest", withProps: props)
```

[PublishLocalRecordTest.swift #18](PublishLocalRecordTest.swift#L18)

Note that this example as it is won't show a massive change in quality between what's streamed and what's recorded - the bitrate is already set to an appropriate value for the size. For a better representation of the difference, setting a high resolution in `tests.plist` and increasing the multiplier for the `vidRate` will make the difference more apparent.

## Important note about Audio Bitrate

Apple's implementation of audio recording doesn't permit all combinations of sample rate and bitrate. For example, while audio at 44.1khz can be set to most bitrates, the default 16khz that our sdk uses will throw an error while recording audio if the bitrate is set to 64kbps, but will work fine at 32kbps. As these errors will prevent files from being created correctly, please ensure you test any recording settings before release, especially when setting a higher bitrate for recording.

## Saving to a specific Album

In the same way that a property can be added to a properties dictionary to change the output quality, another key will allow specifying the title of the album to save the video to.

Similarly to changing the bitrates, simply add `R5RecordAlbumName: "<name here>"` to a dictionary object and pass it to the `R5Stream.record(withName,withProps)` function.

Note that if you are using Swift and wish to both change a bitrate and set an album, this will throw an error unless you cast the collection explicitly with `as [String : Any]`

## Note about file names

iOS saves anything that's added to its camera roll with a semi-random name. However, the name that's passed to `record` is used as the `title` metadata of the video, and on export from the Photos desktop app, that title becomes the file name as one of the default options. Note, as with everything Apple-made, some settings may cause different behavior.
