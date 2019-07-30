# Two Way with the Stream Manager

With clustering, we need to determine which red5 pro instance the client will use. The other examples used a static configuration ip for streaming endpoints. Basic clustering uses more than one stream endpoint for subscribers. Advanced clustering uses more than one endpoint for publishers also.

With the Stream Manager, our configuration ip will be used similarly for publishers and subscribers. Both publishers and subscribers will call a web service to receive the ip that should be used.

### Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[TwoWayStreamManagerTest.swift](TwoWayStreamManagerTest.swift)***

### Running the Example

Like the other Two Way example, you need two devices running it, and the second will need to hit `swap streams` in the home settings, so that they're publishing and subscribing to each other. You will also need to have pointed the app to a properly deployed cluster origin server.

### Setup

In order to stream, you first need to connect to the origin server's Stream Manager. The Stream Manager will know which edges are active and provide the one that needs to be published to. For the publisher we add the action `broadcast` to the web call, while we send `subscribe` for the subscribers.

```Swift
let originURI = "http://" + (Testbed.getParameter(param: "host") as! String) + portURI + "/streammanager/api/2.0/event/" +
            (Testbed.getParameter(param: "context") as! String) + "/" + streamName + "?action=" + action

NSURLConnection.sendAsynchronousRequest(
    NSURLRequest( url: NSURL(string: originURI)! as URL ) as URLRequest,
    queue: OperationQueue(),
    completionHandler:{ (response: URLResponse?, data: Data?, error: Error?) -> Void in
```

[TwoWayStreamManagerTest.swift #30](TwoWayStreamManagerTest.swift#L30)

The service returns a json object with the information needed to connect to publish.

```Swift
do{
    json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [String: AnyObject]
}catch{
    print(error)
    return
}

if let ip = json["serverAddress"] as? String {
```

[TwoWayStreamManagerTest.swift #45](TwoWayStreamManagerTest.swift#L45)

### Knowing When to Subscribe

Like with any stream, you can't subscribe to a stream until it's been published. To know what streams are available to subscribe to with clustering, use the `list` function of the Stream Manager api.

```Swift
let url = "http://" + domain + ":5080/streammanager/api/2.0/event/list"
let request = URLRequest.init(url: URL.init(string: url)!)

NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.init(), completionHandler: { (response: URLResponse?, data: Data?, error: Error?) -> Void in
```

[TwoWayStreamManagerTest.swift #69](TwoWayStreamManagerTest.swift#L69)

Like using `streams.jsp` on a solo server, on success this returns a JSON array of dictionaries. For our purposes, the only property we care about in the dictionary is `name` - as we need to compare it against the name we've set up to subscribe to.

```Swift
let list = try JSONSerialization.jsonObject(with: data!) as! Array<Dictionary<String, String>>;
                    
for dict:Dictionary<String, String> in list {
  if(dict["name"] == (Testbed.getParameter(param: "stream2") as! String)){
```

[TwoWayStreamManagerTest.swift #80](TwoWayStreamManagerTest.swift#L80)

For more information on this and other parts of the Stream Manager API, see our dcumentation [here](https://www.red5pro.com/docs/autoscale/streammanagerapi-v2.html)
