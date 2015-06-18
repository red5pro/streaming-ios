#Subscribing on Red5 Pro

This example shows how to easily subscribe to a Red5 Pro stream.

###Example Code
- ***[SubscribeExample.m](
https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/Examples/Subscribe/SubscribeExample.m)***

- ***[BaseExample.m](
https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/BaseExample.m)***


##How to Subscribe
Subscribing to a Red5 Pro stream requires a few components to function fully.
####Setup R5Connection
The R5Connection manages the connection that the stream utilizes.  You will need to setup a configuration and intialize a new connection.

```Objective-C
	//Setup a configuration object for our connection
    R5Configuration *config = [[R5Configuration alloc] init];
    config.host = [dict objectForKey:@"domain"];
    config.contextName = [dict objectForKey:@"context"];
    config.port = [(NSNumber *)[dict objectForKey:@"port"] intValue];
    config.protocol = 1;
    config.buffer_time = 1;
    
    //Create a new connection using the configuration above
    R5Connection *connection = [[R5Connection alloc] initWithConfig: config];
```
<sup>
[SubscribeExample.m #29](https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/Examples/Subscribe/SubscribeExample.m#L29)
</sup>

####Setup R5Stream
The `R5Stream` handles both subscribing and publishing.  Creating one simply requires the connection already created.

```Objective-C
	//Create our new stream that will utilize that connection
    self.subscribe = [[R5Stream alloc] initWithConnection:connection];
    
    //Setup our listener to handle events from this stream
    self.subscribe.delegate = self;

```
<sup>
[SubscribeExample.m #46](https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/Examples/Subscribe/SubscribeExample.m#L46)
</sup>

The `R5StreamDelegate` that is assigned to the `R5Stream` will receive status events for that stream, including connecting, disconnecting, and errors.


#### Preview the Subscribeer
The `R5VideoViewController` will present publishing streams as well as subscribed streams.  To view the subscribing stream, it simply needs to attach the `R5Stream`.  

>For a more complete example of the `R5VideoViewController`, view the [PublishExample](https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/Examples/Publish).  For this example we will simply utilize `BaseExample.setupDefaultR5ViewController`


####Start Subscribing
The `R5Stream.Subscribe` method will establish the server connection and begin Subscribing.  

```Objective-C
    //start subscribing!!
    [self.subscribe play:[self getStreamName:SUBSCRIBE] ];
```
<sup>
[SubscribeExample.m #57](https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/Examples/Subscribe/SubscribeExample.m#L57)
</sup>
