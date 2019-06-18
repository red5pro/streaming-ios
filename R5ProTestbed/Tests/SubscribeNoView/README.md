# Subscriber With No View

Streams don't need to be connected to a view in order to work. While that will prevent them from displaying video, if a stream is audio-only, it will still play completely. The example will look very similar to the basic subscribe example, with the notable exception that a display doesn't need to be created or attached.

### Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[SubscribeNoViewTest.swift](SubscribeNoViewTest.swift)***

## Running the example

Begin by publishing to **stream1** from a second device.  This stream should be audio only, but if it has video, that won't prevent the audio from playing.

Select the example and it should begin playing any audio that is picked up by the other device.
