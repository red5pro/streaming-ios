# Publisher Authentication using Red5 Pro
This is an example of authenticating a Broadcast for stream playback.

### Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[PublishAuthTest.swift](PublishAuthTest.swift)***

> This example requires you to enable the `SimpleAuthentication` Plugin for the `live` webapp. More information: [https://www.red5pro.com/docs/](https://www.red5pro.com/docs/).

## Authenticating
With the username and password known from the Red5 Pro Server `webapps/live/WEB-INF/simple-auth-plugin.credentials` file (if following the basic auth setup of the Red5 Pro Server), those values are provided to the `parameters` attribute of the `R5Configuration` instance delimited and appended with a semicolon (`;`).

For example, if you have defined the authorization of a username `foo` with a password `bar`, the configuration addition would look like the following:

```swift
let config = R5Configuration()
...
config.parameters = "username=foo;password=bar;"
```

### Example

In the example, the `username` and `password` values are defined in the [test.plist](../../tests.plist#L180-L186) file entry for the *Publish - Auth* test. They are accessed and provided to the `R5Configuration` instance prior to establishing a connection:

```swift
// Set up the configuration
let config = getConfig()
let username = Testbed.localParameters!["username"] as! String
let password = Testbed.localParameters!["password"] as! String
config.parameters = "username=" + username + ";password=" + password + ";"

// Set up the connection and stream
let connection = R5Connection(config: config)
setupPublisher(connection: connection!)
```

[PublishAuthTest.swift #22](PublishAuthTest.swift#L22)

If the provided credentials match those defined for the `live` webapp in its Simple Authentication properties, then the broadcast will begin as normal. If the credentials _do not_ match, the broadcast will be rejected.

