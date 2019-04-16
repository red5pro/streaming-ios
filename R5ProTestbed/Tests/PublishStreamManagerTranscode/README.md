# Stream Manager Publishing with Transcoder

With clustering, we need to determine which Red5 Pro instance the client will use. The other examples used a static configuration address for streaming endpoints. Basic clustering uses more than one stream endpoint for subscribers. Advanced clustering uses more than one endpoint for publishers also.

With the Stream Manager, our configuration IP will be used similarly for publishers and subscribers. Both publishers and subscribers will call a web service to receive the IP that should be used.

## Transcoder Support

To enable Adaptive Bitrate (ABR) control of a stream being played back by a consumer, you need to POST a provision to the Stream Manager detailing the variants at which you will be broadcasting.

For scenarios in which the broadcaster does not have the capability of publishing the variants of the provision, the broadcaster can request that the server does the Transcoding to the variants.

To do so, the broadcast most locate the server address of the Transcoder using the transcode=true query param, from which one of the variants will be broadcast to. The tTranscoder will that generate the additional variants for consumption.

> To learn more about the `transcode` query for API, please visit the documentation: [Stream Manager REST API](https://www.red5pro.com/docs/autoscale/streammanagerapi.html#rest-api-for-streams).

## Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[PublishStreamManagerTranscodeTest.swift](PublishStreamManagerTranscodeTest.swift)***

# Setup

In order to publish using the transcoder, you need to request to endpoint for the transcoder from the Stream Manager just as you would in accessing the Origin endpoint in a normal Stream Manager request for broadcast. To do so, append the `transcode=true` query param on the end of the API request.

```Swift
let urlString = "https://" + (Testbed.getParameter("host") as! String) + ":5080/streammanager/api/3.1/event/" +
  Testbed.getParameter("context") as! String + "/" +
  Testbed.getParameter("stream1") as! String + "?action=broadcast&transcode=true"

NSURLConnection.sendAsynchronousRequest(
  NSURLRequest( URL: NSURL(string: urlString)! ),
  queue: NSOperationQueue(),
  completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
```

[PublishStreamManagerTranscodeTest.swift #122](PublishStreamManagerTranscodeTest.swift#L122)

The service returns a JSON object with the information needed to connect and publish to the transcoder.

```Swift
do {
  let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
} catch {
  print(error)
  return
}
 
if let ip = ["serverAddress"] as? [String: AnyObject] ...
```

[PublishStreamManagerTranscodeTest.swift #44](PublishStreamManagerTranscodeTest.swift#L44)

## Broadcast Stream Name

When using the Transcoder, a set of provisioning variants needs to be provided to the server (as mentioned in the documentation: [Stream Manager REST API](https://www.red5pro.com/docs/autoscale/streammanagerapi.html#rest-api-for-streams)).

When you start a broadcast to the Transcoder, it is recommended you configure your broadcast session with the details from the highest variant and start the stream with the associated stream name of the variant; in the case of this example, it is the `stream1` configuration name appended with `_1` (i.e., `mystream_1`).
