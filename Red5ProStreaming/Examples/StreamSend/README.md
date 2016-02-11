#Auto Reconnection and Events

`R5Stream.send` allows the publisher to send messages to the server to be sent to all subscribers.


###Example Code
- ***[StreamSendExample.m](StreamSendExample.m)***

- ***[BaseExample.m](
https://github.com/red5pro/streaming-ios/blob/master/Red5ProStreaming/BaseExample.m)***

##Running the example
Two devices are required to run this example.  One as a publisher, and the other as a subscriber. 

Connect the first device (publisher) and make sure the Toggle **Swap Names** is *NOT* selected.  Select the **StreamSend** option to begin publishing.

Connect the second device (subscriber) and toggle the **Swap Names** to on.  This will let the example match the name of the publisher application, and notify the example that this is the subscriber.

Touch the **Send** button on the publisher screen to display a toast with the message value on the subscriber.


##Using the R5Stream send
Once the stream has connected you are able to dispatch messages to any connected subscribers.  Sending the message is a simple call:

```Objective-C
	[self.publish send:@"onStreamSend" withParam:@"value=A simple string"];

```
<sup>
[StreamSendExample.m #74](StreamSendExample.m#L74)
</sup>

###Send Message Format
The publisher send has a specific parameter format that must be observed.  A single string variable is able to be sent, and contains a map of all key-value pairs sepereated by a semi-colon.

```Objective-C
@"key1=value1;key2=value2;key3=value3;"
```
Not using this format can result in parsing failure on the server and messages will not be dispatched.

##Receiving R5Stream send calls
In order to handle `R5Stream.send` calls from the publisher, the `R5Stream.client` delegate must be set.  This delegate will receive all `R5Stream.send` messages via appropriately named methods.

```Objective-C
self.subscribe.client = self;
```
<sup>
[StreamSendExample.m #61](StreamSendExample.m#L61)
</sup>

Because the publisher will be sending **onStreamSend**, the subscriber client delegate will need a matching method signature.  All methods receive a single string argument containing the variable map provided by the publisher.  This map can easily be parsed.

```
-(void)onStreamSend:(NSString*)value{

    //get all key value pairs split
    NSArray *pairs = [value componentsSeparatedByString:@";"];
    for(int i=0;i<pairs.count;i++){
        NSArray *keyvalue = [[pairs objectAtIndex:i] componentsSeparatedByString:@"="];
        if(keyvalue.count > 1){
                NSLog(@"Key: %@\nValue: %@", keyvalue[0], keyvalue[1]);
                [ALToastView toastInView:[[[UIApplication sharedApplication] keyWindow] rootViewController].view withText:[NSString stringWithFormat:@"Stream Send Value: %@", keyvalue[1]]];
            
        }
    }
    
}
```
<sup>
[StreamSendExample.m #94](StreamSendExample.m#L94)
</sup>
