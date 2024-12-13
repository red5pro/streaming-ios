# Subscribing to Transcoded Stream over Stream Manager

This example show how to rquest a provision list for a transcoded video over Stream Manager and select playback.

## Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[SubscribeStreamManagerTranscoderTest.swift](SubscribeStreamManagerTranscoderTest.swift)***

# Setup

You will first need to define a provision and begin publishing to the highest variant with a supported broadcaster.

> For ease we have provided an publisher example to do so: [PublishStreamManagerTranscode](../PublishStreamManagerTranscode)

# Requesting Transcoder Provision

In the example, a request for the transcoder provision is made prior to:

1. Making a subsequent request for the Edge to which to subscribe.
2. Requesting subscription for playback.

## Provision

The following is an example of the schema for the provision previously posted - such as from the[PublishStreamManagerTranscode](../PublishStreamManagerTranscode):

```json
[
  {
    "streamGuid": "live/test",
    "streams": [
      {
        "streamGuid": "live/test_3",
        "abrLevel": 3,
        "videoParams": {
          "videoWidth": 320,
          "videoHeight": 180,
          "videoBitRate": 500000
        }
      },
      {
        "streamGuid": "live/test_2",
        "abrLevel": 2,
        "videoParams": {
          "videoWidth": 640,
          "videoHeight": 360,
          "videoBitRate": 1000000
        }
      },
      {
        "streamGuid": "live/test_1",
        "abrLevel": 1,
        "videoParams": {
          "videoWidth": 1280,
          "videoHeight": 720,
          "videoBitRate": 2000000
        }
      }
    ]
  }
]
```

## Access and Authorization

To access the provision held on the server, use the Stream Manager API to access variant stream listing within a provision associated with a root `streamGuid`, which is a combination of the app context and root stream name - for the pursoses of this example, that will be `live/test`.

Prior to the request for the provision an authorization token is required:

To request an authorization token:

```Swift
let data = "\(username):\(password)".data(using: .utf8)!
let base64String = data.base64EncodedString()
let url = "https://\(host)/as/v1/auth/login"
var request = URLRequest(url: URL(string: url)!)
request.httpMethod = "PUT"
request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")

let session = URLSession.shared
let task = session.dataTask(with: request) { data, response, error in
        // Handle response
    if let error = error {
        print("Error: \(error)")
        resolve(nil, error)
        return
    }

    if let httpResponse = response as? HTTPURLResponse {
        print("Status code: \(httpResponse.statusCode)")
        if let data = data {
            // Handle data
            print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
            if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                var json: [String: AnyObject]
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! [String: AnyObject]
                    if let errorMessage = json["errorMessage"] as? String {
                        resolve(nil, AccessError.error(message: errorMessage))
                    } else if let token = json["token"] as? String {
                        resolve(token, nil)
                    }
                } catch {
                    print(error)
                    return
                }
            }
        }
    }
}
```

Then, using the token, request the provision:

```Swift
let host = (Testbed.getParameter(param: "host") as! String)
let version = (Testbed.getParameter(param: "sm_version") as! String)
let nodeGroup = (Testbed.getParameter(param: "sm_nodegroup") as! String)
let url = "https://\(host)/as/\(version)/streams/provision/\(nodeGroup)/\(streamGuid)"

var request = URLRequest(url: URL(string: url)!)
request.httpMethod = "GET"
request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

let session = URLSession.shared
let task = session.dataTask(with: request) { data, response, error in
        // Handle response
    if let error = error {
        print("Error: \(error)")
        self.showInfo(title: "Error", message: String(error.localizedDescription))
        return
    }
    
    let dataAsString = NSString( data: data!, encoding: String.Encoding.utf8.rawValue)
    
    //   The string above is in JSON format, we specifically need the serverAddress value
    var json: [String: AnyObject]
    do{
        json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [String: AnyObject]
    }catch{
        print(error)
        return
    }

    if let streams = json["streams"] as? Array<AnyObject> {
        ...
    }
}
```

Once successul, the `streams` list is used to display the available stream variants to select from. The variant `streamGuid` is then used in requesting an Edge for stream playback; for the purposes of this example, the available `streamGuid` values would be `live/test_1`, `live/test_2` and `live/test_3`.

## Subscribing to a Variant

From the JSON list returned, the example provides the user to select which variant to being subscribing to. Upon selection:

1. A request on the Stream Manager is made to get the available Edge(s) that have the desired stream variant.
2. If successful, a request to being playback of the stream on the provided Edge(s).

### Requesting an Edge and Subscribe

With the target variant and `streamGuid`, request an Edge that the stream variant resides on to begin subscribing:

```Swift
let host = (Testbed.getParameter(param: "host") as! String)
let port = (Testbed.getParameter(param: "server_port") as! String)
let portURI = port == "80" ? "" : ":" + port
let version = (Testbed.getParameter(param: "sm_version") as! String)
let nodeGroup = (Testbed.getParameter(param: "sm_nodegroup") as! String)

let edgeURI = "\(host)\(portURI)/as/\(version)/streams/stream/\(nodeGroup)/subscribe/\(streamGuid)"
let httpString = "http://" + edgeURI
let httpsString = "https://" + edgeURI

var urls = [httpString, httpsString]
requestEdge(urls.popLast()!, resolve: responder(urls: urls))
```

The service returns a JSON array of Origin nodes available to connect to; in typical deployments, this will be of a length of one.

```Swift
var json: [[String: AnyObject]]
do {
    json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [[String: AnyObject]]
} catch {
    print(error)
    return
}

if let edge = json.first {
    if let ip = edge["serverAddress"] as? String {
        NSLog("Retrieved %@ from %@, of which the usable IP is %@", dataAsString!, url, ip);
        resolve(ip, error)
    }
    else if let errorMessage = edge["errorMessage"] as? String {
        resolve(nil, AccessError.error(message: errorMessage))
    }
}
```

The Edge address is then used as the `host` configuration property in order to subscriber to the stream.

> The server will handle when to switch the stream variant on the client based on bandwidth and network availability.
