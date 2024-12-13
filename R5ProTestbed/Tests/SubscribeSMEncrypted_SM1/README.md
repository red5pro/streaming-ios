#Encrypted Stream Manager Subscribing

Using a stream manager doesn't prevent your streams from being encrypted - the same configuration can be used to protect the contents of your broadcasts in any server configuration.

###Example Code
- ***[BaseTest.swift](../BaseTest.swift)***
- ***[SubscribeStreamManagerTest.swift](../SubscribeStreamManager/SubscribeStreamManagerTest.swift)***
- ***[SubscribeSMEncryptedTest.swift](SubscribeSMEncryptedTest.swift)***

###The One Change
The only change from the [basic Stream Manager example](../SubscribeStreamManager/) is that value that the `protocol` setting of the configuration is set to. The `1` in the base example refers to the basic `r5_rtsp` setting. Setting the protocol to use `r5_srtp` is all you need to do to signal the SDK to negotiate an encrypted session.

```Swift
config.`protocol` = Int32(r5_srtp.rawValue)
```
<sup>
[SubscribeSMEncryptedTest.swift #37](SubscribeSMEncryptedTest.swift#L37)
</sup>

###Further Security Concerns
As with the basic Encryption example, it's suggested that some form of stream authentication is used. Additionally, it's suggested that the innitial negotiation to find the server to broadcast to be done over HTTPS (iOS defaults to HTTPS where available) to prevent a malicious party from connecting to the returned server first. Note - SRTP does not require the server to have an SSL certificate, and so this example is set to run without HTTPS to run on more servers, but HTTPS will require the server to be set up with an appropriate SSL certificate, and the port must not be added to the Stream Manager API request for it to connect correctly.
