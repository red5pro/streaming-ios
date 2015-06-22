#Auto Reconnection and Events

This example demonstrates using the status updates from `R5Stream`.  A timer is used to attempt to reconnect to a stream that has not yet been published.

To use the example, launch the Auto Reconnect feature in the app and you will see it attempting to connect to stream 'subscriber'.  Launch a publisher app with the name 'subscriber' after you have launched this example, and it will successfully connect after the stream has started.
 


###Example Code
- ***[AutoReconnectExample.m](/AutoReconnectExample.m)***

- ***[BaseExample.m](
https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/BaseExample.m)***


##Handling Status Updates from R5Stream
When the `R5Stream.delegate` is set, all events will be sent through the  `R5StreamDelegate.onR5SteamStatus: withStatus: withMessage:` method.  

The status code passed in is an `r5_status` enum that can be seen [here](https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/R5Streaming.framework/Headers/global.h#L93).

This example receives the status event, and if there was a connection error, will start a timer to reconnect the stream in 8 seconds.  The message included with the error will display in a toast in the super method.

```Objective-C
-(void)onR5StreamStatus:(R5Stream *)stream withStatus:(int)statusCode withMessage:(NSString *)msg{

    //if we error out - reconnect!
    if(statusCode == r5_status_connection_error){
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(reconnect:) userInfo:nil repeats:NO];
    }
    
    [super onR5StreamStatus:stream withStatus:statusCode withMessage:msg];
}

```
<sup>
[AutoReconnectExample.m #39](/AutoReconnectExample.m#L39)
</sup>

