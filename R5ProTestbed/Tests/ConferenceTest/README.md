# Conferencing

This example shows how to connect to multiple other participants in a group chat, using shared objects to serve as a room control.

This example was made to be compatible with the [WebRTC Conference Example](https://github.com/red5pro/streaming-html5/tree/master/src/page/test/conference)

To mute audio or video after starting, tap the screen and press the related button. To dismiss the buttons, tap the screen again.

## Known Issues

After a certain number of participants (depending on hardware) the individual views of each person may flicker. This is an issue with concurrent calls to OpenGL and has been addressed for the next release of the Red5Pro SDKs.

Echo Cancellation is unreliable after 3 participants. Headphones are strongly encouraged.
