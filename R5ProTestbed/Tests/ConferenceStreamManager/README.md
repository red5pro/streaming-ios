# Conference Chat

This example demonstrates multi-party communication using Red5 Pro. It should be used in conjunction with a conference WebSocket host such as [this example](https://github.com/red5pro/red5pro-conference-host).

It is recommended to view this example as part of the `webrtcexamples` webapp shipped with the [Red5 Pro Server](https://account.red5.net/download).

## Basic Publisher

**Please refer to the [Basic Publisher Documentation](../Publish/README.md) to learn more about the basic setup of a publisher.**

## Basic Subscriber

**Please refer to the [Basic Subscriber Documentation](../Subscribe/README.md) to learn more about the basic setup of a subscriber.**

## Example Code

- **[ConferenceTest.swift](ConferenceTest.swift)**
- **[ConferenceViewController.swift](ConferenceViewController.swift)**

# Setup

## WebSocket Conference Host

The `WebSocket Conference Host` refers to the socket endpoint that manages the list of active streams and their scopes for a given conference session.

We have provided a basic example at [https://github.com/red5pro/red5pro-conference-host](https://github.com/red5pro/red5pro-conference-host).

The endpoint for the `WebSocket Conference Host` is defined in the **tests.plist** as the `conference_host` property. By default it is set to a local IP address and port on your network (e.g., `ws://10.0.0.75:8001`). Change this to either the local IP or the remote IP of the machine that you launch the `WebSocket Conference Host` on.

> The reason it is defined as a local IP on your network and not `localhost` is because `localhost` would refer to the actual device that the testbed is launched on. We assume you would not also be running the `WebSocket Conference Host` NodeJS server on your iOS device :)

Once a publish session has begun, a connection to the `WebSocket Conference Host` is established and messages with regards to active stream listing are handled:

```swift
@objc func connectSocket () {
    // Endpoint location of host. See: https://github.com/red5pro/red5pro-conference-host
    // Note: Even though you may launch the conference host server on localhost, you cannot
    //          specify `localhost` in the URL. You need to define the private IP of your machine on the
    //          same router that the tethered iOS device is on (e.g., 10.0.0.x).
    //          This is because defining `localhost` as the endpoint here would indicate your iOS device.
    let host = Testbed.getParameter(param: "conference_host" as String)?
        .replacingOccurrences(of: "http:", with:"ws:")
        .replacingOccurrences(of: "https:", with: "wss:")
    let url = URL(string: "\(host!)?room=\(self.roomName!)&streamName=\(self.pubName!)")
    socket = WebSocketProvider(url: url!)
    socket?.delegate = self
    socket?.connect()
}

func webSocketDidConnect(_ webSocket: WebSocketProvider) {}
func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {}

func webSocket(_ webSocket: WebSocketProvider, didReceiveMessage message: String) {
    // message = { room: str, streams: str[] }
    let json: AnyObject? = message.parseJSONString
    let jsonDict = json as? [String: Any]

    if jsonDict?["room"] as? String == self.roomName! {
        if let streams = jsonDict?["streams"] as? Array<String> {
            stringToQueue(incoming: streams.joined(separator: ","))
        }
    }
}
```

## Starscream

By default, the WebSocket implementation used is the [Starscream](https://github.com/daltoniam/Starscream) iOS library. It is installed via the `Swift Package Manager`.

