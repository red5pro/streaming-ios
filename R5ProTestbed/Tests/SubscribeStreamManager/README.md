#Stream Manager Subscribing

With clustering, we need to determine which red5 pro instance the client will use. The other examples used a static configuration ip for streaming endpoints. Basic clustering uses more than one stream endpoint for subscribers. Advanced clustering uses more than one endpoint for publishers also.With the Stream Manager, our configuration ip will be used similarly for publishers and subscribers. Both publishers and subscribers will call a web service to receive the ip that should be used.

###Example Code
- ***[BaseTest.swift](../BaseTest.swift)***
- ***[SubscribeStreamManagerTest.swft](SubscribeStreamManagerTest.swft)***

###Setup
In order to subscribe, you first need to connect to the origin server's Stream Manager. The Stream Manager will know which edges are active and provide the one that you need to subscribe from.

```Swift
let urlString = "https://" + (Testbed.getParameter("host") as! String) + ":5080/streammanager/api/1.0/event/" +
	Testbed.getParameter("context") as! String + "/" +
	Testbed.getParameter("stream1") as! String + "?action=subscribe"
        
NSURLConnection.sendAsynchronousRequest(
	NSURLRequest( URL: NSURL(string: urlString)! ),
	queue: NSOperationQueue(),
	completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
```
<sup>
[SubscribeStreamManagerTest.java #24](SubscribeStreamManagerTest.java#L24)
</sup>

The service returns a json object with the information needed to connect to subscribe.

```Swift
do{
	let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
}catch{
	print(error)
	return
}
                
let ip = ["serverAddress"]
```
<sup>
[SubscribeStreamManagerTest.swft #48](SubscribeStreamManagerTest.swft#L48)
</sup>
