# Bandwidth Detection with Red5 Pro

This example shows how to easily detect upload and download bandwidth with Red5 Pro prior to beginning a stream.

## Example Code

* **_[BaseTest.swift](../BaseTest.swift)_**
* **_[BandwidthDetectionTest.swift](BandwidthDetectionTest.swift)_**

## How to Check Bandwidth

Checking the bandwidth (download and upload simultaneously) prior to beginning a stream is relatively simple, requiring only a few pieces of setup.

1. One must [instantiate an `R5BandwidthDetection` instance](BandwidthDetectionTest.swift#L26)
2. One must then [utilize the `checkSpeeds` method](BandwidthDetectionTest.swift#L32) of that instance
3. Doing so requires passing in:
	1. The base url (usually the same as the `host` you would provide to your `R5Configuration`)
	2. How long you wish the total bandwidth test to take, in seconds
	3. Callback blocks for the successful and unsuccessful attempts at checking the bandwidth

A simplified example of this would be:

```swift
let detection = R5BandwidthDetection()

detection.checkSpeeds("your-host", forSeconds: 2.5, withSuccess: { (response) in
    let responseDict = response! as NSDictionary
    let download = Int32(responseDict.object(forKey: "download") as! Int)
    let upload = Int32(responseDict.object(forKey: "upload") as! Int)

    print("Download speed is \(download)Kbps\nUpload speed is \(upload)Kbps\n")
}) { (error) in
    print("There was an error checking your speeds! \(error?.localizedDescription ?? "Unknown error")")
}
```

The rest of this example is based on [SubscribeTest.swift](../Subscribe/) and ensures that a [minimum bandwidth](BandwidthDetectionTest.swift#L38) (as [defined by the `tests.plist` file](../tests.plist#L11-12)) is met prior to subscribing to the stream.
