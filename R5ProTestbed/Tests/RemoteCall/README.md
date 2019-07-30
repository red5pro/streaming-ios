# Remote Procedure Calls

`R5Stream.send` allows the publisher to send messages to the server to be sent to all subscribers.

### Example Code

- ***[PublishRemoteCallTest.swift](PublishRemoteCallTest.swift)***
- ***[SubscribeRemoteCallTest.swift](SubscribeRemoteCallTest.swift)***

- ***[BaseTest.swift](../BaseTest.swift)***

## Running the example

Two devices are required to run this example.  One as a publisher, and the other as a subscriber. 

Connect the first device (publisher) with the Publish - Remote Call example. On the second device (subscriber) use the Subscribe - Remote Call example.

Touch the preview on the publisher screen to display a label on the subscriber screen where the publisher touched.

## Using the R5Stream send

Once the stream has connected you are able to dispatch messages to any connected subscribers.  Sending the message is a simple call:

```Swift
publishStream?.send("whateverFunctionName", withParam: sendString)
```

[PublishRemoteCallTest.swift #60](PublishRemoteCallTest.swift#L60)

### Send Message Format

The publisher send has a specific parameter format that must be observed.  A single string variable is able to be sent, and contains a map of all key-value pairs sepereated by a semi-colon.

```Swift
"key1=value1;key2=value2;key3=value3;"
```

Not using this format can result in parsing failure on the server and messages will not be dispatched.

## Receiving R5Stream send calls

In order to handle `R5Stream.send` calls from the publisher, the `R5Stream.client` delegate must be set.  This delegate will receive all `R5Stream.send` messages via appropriately named methods.

```Swift
self.subscribeStream?.client = self;
```

[SubscribeRemoteCallTest.swift #27](SubscribeRemoteCallTest.swift#L27)

Because the publisher will be sending **whateverFunctionName**, the subscriber client delegate will need a matching method signature. As the name implies, the function can be named anything as long as it is publicly accessible. All methods receive a single string argument containing the variable map provided by the publisher.  This map can easily be parsed.

```Swift
func whateverFunctionName(message: String){

  NSLog("Got this message: " + message)

  let splitMessage = message.characters.split(";").map(String.init)

  var message : String = ""
  var point : CGPoint = CGPoint()

  for item in splitMessage {

    let itemSplit = item.characters.split("=").map(String.init)
    let size = self.view.frame.size
    switch itemSplit[0] {
    case "message":
      message = itemSplit[1]
      break
    case "touchX":
      point.x = CGFloat((itemSplit[1] as NSString).doubleValue) * size.width
      break
    case "touchY":
      point.y = CGFloat((itemSplit[1] as NSString).doubleValue) * size.height
      break
        default:
            break
        }
    }
```

[SubscribeRemoteCallTest.swift #36](SubscribeRemoteCallTest.swift#L36)
