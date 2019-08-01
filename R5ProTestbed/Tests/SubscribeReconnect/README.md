# Subscribe Auto Reconnect Test

This example utilizes overriding the `onR5StreamStatus` method to test for and attempt to recover from connection errors by resubscribing after some preconfigured amount of time.

## Example Code

- **_[BaseTest.swift](../BaseTest.swift)_**
- **_[SubscribeAutoReconnectTest.swift](SubscribeAutoReconnectTest.swift)_**

# Implementation

Use the `Streams API` of the Red5 Pro Server to request the list of active publish streams. Once the stream is available in the listing, it can be subscribed to.
If the stream goes away - such as a loss or stop in broadcast - restart a timer to request the stream listing using the `Streams API` again.

## Streams API

The `Streams API` of the Red5 Pro Server can be found in the default location of the `live` webapp. Making a `GET` request on the `streams.jsp` file will return a JSON array of streams.

> If streaming to a different webapp context other than `live`, you will need to move the `streams.jsp` file and update the web configs as needed.

```swift
func findStreams() {
    let domain = Testbed.getParameter(param: "host") as! String
    let app = Testbed.getParameter(param: "context") as! String
    let urlPath = "http://" + domain + ":5080" + "/" + app + "/streams.jsp"
    let streamName = Testbed.getParameter(param: "stream1") as! String

    var request = URLRequest(url: URL(string: urlPath)!)
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let session = URLSession.shared

    NSLog("Requesting stream list...")

    session.dataTask(with: request) {data, response, err in

        if err == nil {
//                let resut = data as String
            do {

                NSLog("Stream list received...")
                //   Convert our response to a usable NSString
                let list = try JSONSerialization.jsonObject(with: data!) as! Array<Dictionary<String, String>>;

                var exists: Bool = false;
                for dict:Dictionary<String, String> in list {
                    if(dict["name"] == streamName){
                        exists = true;
                        break;
                    }
                }

                DispatchQueue.main.async {
                    if (exists) {
                        NSLog("Publisher exists, let's try connecting...")
                        self.Subscribe(streamName)
                    }
                    else {
                        NSLog("Publisher does not exist.")
                        self.reconnect()
                    }
                }

            }
            catch let error as NSError {
                NSLog(error.localizedFailureReason!)
            }
        }
        else {
            NSLog(err!.localizedDescription)
        }

    }.resume()

}
```

[SubscribeAutoreconnectTest.swift #17](SubscribeAutoreconnectTest.swift#L17)

Once the stream the subscriber is attempting to connect to has become available in the stream listing from the `Streams API`, you can continue to create a Subscriber session as you would normally.

## Events & Reconnection

In the occurance of a lost stream from the publisher - either from a network issue or stop of broadcast - you can stop the Subscriber session and start the request cycle on the `Streams API` again.

There are 2 important events that relate to the loss of a publisher:

1. `ERROR`
2. `NET_STATUS` with message of `NetStream.Play.UnpublishNotify`

The first is an event notification that the stream requested to consume as gone away. The second is an event notification that the publisher has explicitly stopped their broadcast.

By listening on these events and knowing their meaning, you can act accordingly in setting up a new request cycle for the `Streams API`:

```javascript
override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {

  super.onR5StreamStatus(stream, withStatus: statusCode, withMessage: msg)

  if(statusCode == Int32(r5_status_connection_close.rawValue)){

    //we can assume it failed here!
    NSLog("Connection closed.")
    self.reconnect()

  }
  else if (statusCode == Int32(r5_status_netstatus.rawValue) && msg == "NetStream.Play.UnpublishNotify") {

    // publisher stopped broadcast. let's resume autoconnect logic.
    let view = currentView
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        if(self.subscribeStream != nil) {
            view?.attach(nil)
            self.subscribeStream!.stop()
            self.subscribeStream = nil
        }
        self.reconnect()
    }
  }

}
```

[SubscribeAutoreconnectTest.java #114](SubscribeAutoreconnectTest.java#L114)
