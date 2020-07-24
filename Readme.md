# Red5 Pro iOS Streaming Testbed

This repository contains a simple project with a number of examples that can be used for testing and reference.

## Requirements

* [Red5 Pro Server](#red5-pro-server)
* [Red5 Pro SDK License Key](#red5-pro-sdk-license-key)

### Red5 Pro Server
You will need a functional, running Red5 Pro server web- (or locally-) accessible for the client to connect to. If you already have a [Red5 Pro Account](https://account.red5pro.com), you can find the Red5 Pro Server download at [https://account.red5pro.com/download](https://account.red5pro.com/download).

> For more information visit [Red5Pro.com](https://red5pro.com).

### Red5 Pro SDK License Key
A Red5 Pro SDK License Key is required to use the iOS Mobile SDK. If you already have a [Red5 Pro Account](https://account.red5pro.com), you can find your Red5 Pro SDK License Key at [https://account.red5pro.com/overview](https://account.red5pro.com/overview).

> You will need to copy the `SDK License` into the `license_key` property field of the [tests.plist](R5ProTestbed/tests.plist).

## Setup

You will need to modify **/Red5ProTestbed/tests.plist (the domain value)** to point to your `host` server instance's IP address and update the `license_key` property to that of your Red5 Pro SDK License.  If you do not, the examples will not function when you build. If you are running the server locally, then your machine and mobile device need to be on the same WiFi network.

Once you have modified your settings, you can run the application for simulator or device.

> ***Note: Publishing does not currently work on simulator!***

## Examples

### [Publishing](R5ProTestbed/Tests/Publish)

| **[1080p](R5ProTestbed/Tests/Publish)**
| :-----
| *A high quality publisher. Note that this is the publish test with a non-default 'bitrate' and camera size values set in tests.plist*
| **[ABR](R5ProTestbed/Tests/AdaptiveBitrate)**
| *A high bitrate publisher with AdaptiveBitrateController*   
| **[Aspect Ratio](R5ProTestbed/Tests/PublishAspect)**
| *A publish example that includes modifying the scale mode of the preview display*
| **[Authentication](R5ProTestbed/Tests/PublishAuth)**
| *An example of publishing a stream as an authenticated user*
| **[AV Category](R5ProTestbed/Tests/PublishAVCategory)**
| *A publish example that includes manual handling of iOS's AV Session*   
| **[Background](R5ProTestbed/Tests/PublishBackground)**
| *An example that continues to publish audio while the app is in the background*
| **[Bandwidth Detection - Upload](R5ProTestbed/Tests/BandwidthDetectionUploadOnly)**
| *An example that tests the upload speed between the device and server before publishing.*
| **[Camera Device Orientation](R5ProTestbed/Tests/PublishCameraDeviceOrientation)**
| *A combination of the `Camera Swap` and `Device Orientation` examples*
| **[Camera Swap](R5ProTestbed/Tests/CameraSwap)**
| *Touch the screen to swap which camera is being used! Verify with flash, android, or other iOS device running subscribe test that camera is swapping properly and no rendering problems occur.*
| **[Custom Audio Source](R5ProTestbed/Tests/PublishCustomMic)**
| *Uses a custom controller to modify audio data for the publisher.*
| **[Custom Video Source](R5ProTestbed/Tests/PublishCustomSource)**
| *Uses a custom controller to supply video data to the publisher.*
| **[Device Orientation](R5ProTestbed/Tests/PublishDeviceOrientation)**
| *Rotate the device to update the orientation of the broadcast stream.  Verify with browser-based players (WebRTC, Flash, HLS), Android, or other iOS device running subscribe test that image is rotating properly and no rendering problems occur.*
| **[Encrypted](R5ProTestbed/Tests/PublishEncrypted)**
| *An example that encrypts all traffic between the device and server.*
| **[Image Capture](R5ProTestbed/Tests/PublishStreamImage)**
| *Touch the publish stream to take a screen shot that is displayed!*
| **[High Quality Audio](R5ProTestbed/Tests/PublishHQAudio)**
| *`R5Microphone.sampleRate` is set to 44100 (the default is 16000).*    
| **[Local Record](R5ProTestbed/Tests/PublishLocalRecord)**
| *A publish example that records stream data locally on the device.*    
| **[Mute/Unmute](R5ProTestbed/Tests/PublishPause)**
| *Touch the screen to toggle between sending Audio & Video, sending just Video, sending just Audio, and sending no Audio or Video. Turning off and on the media sources is considered mute and unmute events, respecitively*
| **[Record](R5ProTestbed/Tests/Recorded)**
| *A publish example that records stream data on the server.*
| **[Remote Call](R5ProTestbed/Tests/RemoteCall)**
| *The publish portion of the remote call example - sends the remote call.*
| **[Stream Manager](R5ProTestbed/Tests/PublishStreamManager)**
| *A publish example that connects with a server cluster using a Stream Manger*
| **[Stream Manager Encrypted](R5ProTestbed/Tests/PublishSMEncrypted)**
| *A publish example that encrypts traffic durring a broadcast over Stream Manager.*
| **[Stream Manager Transcoder](R5ProTestbed/Tests/PublishStreamManagerTranscode)**
| *A publish example that uses transcoding broadcast over Stream Manager.*
| **[Telephony Interrupt](R5ProTestbed/Tests/PublishTelephonyInterrupt)**
| *An example on `"gracefully"` handling interrupts while broadcasting - such as receiving an declining a phone call*
| **[Two Way](R5ProTestbed/Tests/TwoWay)**
| *An example of simultaneously publishing while subscribing - allowing a conversation. Includes stream detection and auto-connection.*
| **[Two Way - Stream Manager](R5ProTestbed/Tests/TwoWayStreamManager)**
| *The two way example, modified to work with a stream manager. Includes stream detection and auto-connection.*
| **[Shared Object](R5ProTestbed/Tests/SharedObject)**
| *An example of sending data and messages between clients through remote shared objects.*
| **[Shared Object Streamless](R5ProTestbed/Tests/SharedObjectStreamless)**
| *An example of using Shared Objects without a media stream.*

### [Subscribing](R5ProTestbed/Tests/Subscribe)

| **[Aspect Ratio](R5ProTestbed/Tests/SubscribeAspectRatio)**
| :----
| *Change the fill mode of the stream.  scale to fill, scale to fit, scale fill.  Aspect ratio should be maintained on first 2.*  
| **[Audio Delay](R5ProTestbed/Tests/SubscribeAudioDelay)**
| *Captures the raw audio from the stream and delays it with a custom buffer implementation*   
| **[Authentication](R5ProTestbed/Tests/SubscribeAuth)**
| *An example of subscribing to a stream as an authenticated user*   
| **[AV Category](R5ProTestbed/Tests/SubscribeAVCategory)**
| *A subscribe example that includes manual handling of iOS's AV Session*
| **[Background](R5ProTestbed/Tests/SubscribeBackground)**
| *A subscribing example that can continue when the app moves into the background*
| **[Bandwidth Test](R5ProTestbed/Tests/SubscribeBandwidth)**
| *Detect Insufficient and Sufficient BW flags.  Test on a poor network using a publisher that has high video quality. Video should become sporadic or stop altogether.  The screen will darken when no video is being received.*   
| **[Bandwidth Detection - Download](R5ProTestbed/Tests/BandwidthDetectionDownloadOnly)**
| *An example that tests the download speed between the device and server before subscribing.*  
| **[Bandwidth Detection - Dual](R5ProTestbed/Tests/BandwidthDetection)**
| *An example that tests both the upload and download speeds between the device and server before subscribing.*
| **[Cluster](R5ProTestbed/Tests/SubscribeCluster)**
| *An example of connecting to a cluster server.*
| **[Encrypted](R5ProTestbed/Tests/SubscribeEncrypted)**
| *An example that encrypts all traffic between the device and server.*
| **[Hardware Acceleration](R5ProTestbed/Tests/SubscribeHardwareAcceleration)**
| *Touch the subscribe stream to take a screen shot that is displayed!*
| **[Image Capture](R5ProTestbed/Tests/SubscribeStreamImage)**
| *Touch the subscribe stream to take a screen shot that is displayed!*
| **[Metal View](R5ProTestbed/Tests/SubscribeMetalView)**
| *Uses a metal based view to display a stream.*
| **[Mute](R5ProTestbed/Tests/SubscribeMuteAudio)**
| *Allows toggle of mute playback.*
| **[No View](R5ProTestbed/Tests/SubscribeNoView)**
| *A proof of using an audio only stream without attaching it to a view.*
| **[Reconnect](R5ProTestbed/Tests/SubscribeReconnect)**
| *An example of reconnecting to a stream on a connection error.*
| **[Remote Call](R5ProTestbed/Tests/RemoteCall)**
| *The subscribe portion of the remote call example - receives the remote call.*
| **[Render Swap](R5ProTestbed/Tests/SubscribeRendererSwap)**
| *Allows swap of renderer for stream playback.*
| **[Render RGB](R5ProTestbed/Tests/SubscribeForceRGBScalar)**
| *Forces RGB Scalar (SW) decoder for stream playback.*
| **[Set Volume](R5ProTestbed/Tests/SubscribeSetVolume)**
| *Shows setting the playback volume for the stream.*
| **[Stream Manager](R5ProTestbed/Tests/SubscribeStreamManager)**
| *A subscribe example that connects with a server cluster using a Stream Manger*
| **[Stream Manager Encrypted](R5ProTestbed/Tests/SubscribeSMEncrypted)**
| *A subsribe example that encrypts traffic while receiving a broadcast over Stream Manager.*
| **[Stream Manager Transcoder](R5ProTestbed/Tests/SubscribeStreamManagerTranscoder)**
| *A subscribe example that demonstrates ABR with the Stream Manager.*
| **[Telephony Interrupt](R5ProTestbed/Tests/SubscribeTelephonyInterrupt)**
| *An example on `"gracefully"` responding to interrupts while subscribed to a broadcasting - such as the publisher receiving an declining a phone call*
| **[Two Streams](R5ProTestbed/Tests/SubscribeTwoStreams)**
| *An example of subscribing to multiple streams at once, useful for subscribing to a presentation hosted by two people using a Two Way connection.*

### Multi

| **[Conference](R5ProTestbed/Tests/ConferenceTest)**
| :-----
| *Demonstrates multi-party communication using Red5 Pro. It also demonstrates using Shared Objects as notifications to recognize the addition and removal of parties broadcasting.*

## Notes

1. For some of the above examples you will need two devices (a publisher, and a subscriber). You can also use a web browser to subscribe or publish via Flash, `http://<your_red5_pro_server>:5080/live`.
2. You can see a list of active streams by navigating to `http://your_red5_pro_server:5080/live/subscribe.jsp` (will need to refresh this page after you have started publishing).

[![Analytics](https://ga-beacon.appspot.com/UA-59819838-3/red5pro/streaming-ios?pixel)](https://github.com/igrigorik/ga-beacon)
