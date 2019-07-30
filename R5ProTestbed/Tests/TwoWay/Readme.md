# Two Way Video Chat

This example demonstrates two way communication using Red5 Pro.  It also demonstrates using Remote Procedure Calls (RPC) on the server.

### Example Code

- ***[TwoWayTest.swift](TwoWayTest.swift)***
- ***[BaseTest.swift](../BaseTest.swift)***

### Setup

Two way communication simply requires setting up a publish stream and a subscribe stream at the same time.  You can test the example with two devices.  On the second device use the "Home" screen to swap the names of the stream. 

The subscriber portion will automatically connect when the second person begins streaming.

### Getting Live Streams

You can make RPC calls to the server using `R5Connection.call`.  The call is similar to `R5Stream.send` but allows you to specify a return method name.

`streams.getLiveStreams` is a built in RPC in all Red5 Pro servers.  This call will return a string value that contains a json array of all streams that are currently publishing.

```Swift
    //call out to get our new stream
    publishStream?.connection.call("streams.getLiveStreams", withReturn: "onGetLiveStreams", withParam: nil)
```

[TwoWayTest.swift #83](TwoWayTest.swift#L83)

The return method will be called on the `R5Stream.client`.  The client will need a method that matches the signature of the return.  Since `streams.getLiveStreams` returns a string, a void method with a single string parameter will handle the result.

```Swift
func onGetLiveStreams (streams : String){

        var names : NSArray

        do{
            names = try NSJSONSerialization.JSONObjectWithData(streams.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
        } catch _ {
            self.timer = NSTimer(timeInterval: 2, target: self, selector: Selector("getStreams"), userInfo: nil, repeats: false)
            return
        }

        for i in 0..<names.count {

            if( Testbed.getParameter("stream2") as! String == names[i] as! String )
            {
                subscribeBegin()
                return
            }
        }

        self.timer = NSTimer(timeInterval: 2, target: self, selector: Selector("getStreams"), userInfo: nil, repeats: false)
    }
```

[TwoWayTest.swift #86](TwoWayTest.swift#L86)

A simple json parsing will get all streams, and start the timer over to request the streams again.  The table view is loaded with the new stream names on the return to display for subscription.
