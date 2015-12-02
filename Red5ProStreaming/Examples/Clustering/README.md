# Subscribing to a Red5 Pro Cluster

<!-- MarkdownTOC -->

1. [Reference](#reference)
2. [Requirements](#requirements)
3. [Explanation](#explanation)
    1. [Connect to your Red5 Pro Cluster](#connect-to-your-red5-pro-cluster)
    2. [Create your `R5Configuration`](#create-your-r5configuration)
    3. [Create your `R5Connection`](#create-your-r5connection)
    4. [Create your `R5Stream`](#create-your-r5stream)
    5. [Assign your `R5Stream` a delegate](#assign-your-r5stream-a-delegate)
    6. [Attach your `R5Stream` to an `R5VideoViewController`](#attach-your-r5stream-to-an-r5videoviewcontroller)
    7. [Subscribe to your `R5Stream`](#subscribe-to-your-r5stream)

<!-- /MarkdownTOC -->

## Reference

This example was built off of our [Subscribe example](../Subscribe/ "Red5 Pro iOS Subscribe Example"), so please see it for any explanation you find lacking within this document.

## Requirements

For this and our [other examples](../ "Red5 Pro iOS Examples"), you will have to edit the base [connection.plist](../../connection.plist "A Red5 Pro configuration dictionary") with appropriate values to suit your own [Red5 Pro](https://red5pro.com/) server and stream(s).

## Explanation

##### [Connect to your Red5 Pro Cluster](./ClusteringExample.m#L33-L40 "Connecting to your Red5 Pro Cluster origin")
Sending a GET request to the Red5 Pro Cluster origin IP's `/cluster` endpoint on port 5080 (the default port) will return an IP with an attached port. For the purposes of subscribing, one only needs to [use the IP portion of the return](./ClusteringExample.m#L51-L54).

```objc
NSString *domain = @"99.98.97.96";
NSString *urlAsString = [NSString stringWithFormat:@"http://%@:5080/cluster", domain];
NSURL *url = [NSURL URLWithString:urlAsString];

[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url]
                                   queue:[NSOperationQueue new]
                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                           // ...
                           NSString *dataAsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                           NSString *ip = [dataAsString substringToIndex:[dataAsString rangeOfString:@":"].location];
                           // ...
                       }];
```

##### [Create your `R5Configuration`](./ClusteringExample.m#L64-L71 "Creating an R5Configuration for Red5 Pro")
Just as one would for the preliminary [Subscribe example](../Subscribe/), create a configuration with values appropriate to your [Red5 Pro](https://red5pro.com/) server and stream(s). These values include your host (_the IP you receive_), the context name (_e.g. "live"_), what port you're using (_8554 by default_), and your stream name.

```objc
R5Configuration *config = [[R5Configuration alloc] init];
config.host = ip;
config.contextName = @"myContext";
config.port = 8554;
config.protocol = 1;
config.buffer_time = 1;
```

##### [Create your `R5Connection`](./ClusteringExample.m#L74 "Creating an R5Connection for Red5 Pro")
Using the `R5Configuration` you've setup, you can create a connection to your [Red5 Pro](https://red5pro.com/) server.

```objc
R5Connection *connection = [[R5Connection alloc] initWithConfig: config];
```

##### [Create your `R5Stream`](./ClusteringExample.m#L79 "Creating an R5Stream for Red5 Pro")
Using the `R5Connection` you've setup, you can create a stream connection to your [Red5 Pro](https://red5pro.com/) server. This stream connection will be what sends messages to your delegate as well as what you attach to your video view controller and tell to play.

```objc
R5Stream *stream  = [[R5Stream alloc] initWithConnection:connection];
```

##### [Assign your `R5Stream` a delegate](./ClusteringExample.m#L82 "Assigning a delegate to a Red5 Pro R5Stream")
The delegate you assign to your `R5Stream` will receive and handle, as you see fit, messages from the `R5Stream` during it's connection and subscription.

```objc
stream.delegate = self;
```

##### [Attach your `R5Stream` to an `R5VideoViewController`](./ClusteringExample.m#L85-L88 "Attaching an R5Stream to an R5VideoViewController for Red5 Pro")
This view controller is what is added to the screen so as to allow visual and audio playback of your stream.

```objc
// R5VideoViewController *r5view = ...
[r5View attachStream:stream];
```

##### [Subscribe to your `R5Stream`](./ClusteringExample.m#L91 "Subscribing to a stream on a Red5 Pro Cluster")
Setting your `R5Stream` to play will start the visual and audio playback of your stream.

```objc
[stream play:[self getStreamName:SUBSCRIBE]];
```
