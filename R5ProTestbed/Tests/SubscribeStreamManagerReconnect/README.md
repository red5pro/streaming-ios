# Stream Manager Subscribing

With clustering, we need to determine which red5 pro instance the client will use. The other examples used a static configuration ip for streaming endpoints. Basic clustering uses more than one stream endpoint for subscribers. Advanced clustering uses more than one endpoint for publishers also.

With the Stream Manager, our configuration IP will be used similarly for publishers and subscribers. Both publishers and subscribers will call a web service to receive the IP that should be used. Since this is an HTTP call, you can use a DNS Name for the `host` value. 

## Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[SubscribeStreamManagerTest.swft](SubscribeStreamManagerTest.swft)***

## Setup

In order to subscribe, you first need to connect to the autoscaling Stream Manager. The Stream Manager will know which edges are active and provide the one that you need to subscribe from.

> **Note:** you will need to start the stream on the main thread.

```Swift
let host = (Testbed.getParameter(param: "host") as! String)
let port = (Testbed.getParameter(param: "server_port") as! String)
let portURI = port == "80" ? "" : ":" + port
let version = (Testbed.getParameter(param: "sm_version") as! String)
let nodeGroup = (Testbed.getParameter(param: "sm_nodegroup") as! String)
let context = (Testbed.getParameter(param: "context") as! String)
let streamName = (Testbed.getParameter(param: "stream1") as! String)

let originURI = "\(host)\(portURI)/as/\(version)/streams/stream/\(nodeGroup)/subscribe/\(context)/\(streamName)"

...
NSURLConnection.sendAsynchronousRequest(
  NSURLRequest( URL: NSURL(string: urlString)! ),
  queue: NSOperationQueue(),
  completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
```

The service returns a JSON array of Origin nodes available to connect to; in typical deployments, this will be of a length of one.

```Swift
var json: [[String: AnyObject]]
do {
    json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [[String: AnyObject]]
} catch {
    print(error)
    self.showInfo(title: "Error", message: String(error.localizedDescription))
    return
}

if let edge = json.first {
    if let ip = edge["serverAddress"] as? String {
        resolve(ip, error)
    }
    else if let errorMessage = edge["errorMessage"] as? String {
        resolve(nil, AccessError.error(message: errorMessage))
    }
}
```

The Edge address is then used as the `host` configuration property in order to subscriber to the stream.

> This test has additional logic for reconnect to playback on non-available and dropped broadcast streams.
