# Bandwidth Detection (Download) with Red5 Pro

This example shows how to easily detect download bandwidth with Red5 Pro prior to subscribing to a stream.

## Example Code

* **_[BaseTest.swift](../BaseTest.swift)_**
* **_[BandwidthDetectionDownloadOnlyTest.swift](BandwidthDetectionDownloadOnlyTest.swift)_**

## How to Check Bandwidth

Checking the download bandwidth prior to subscribing to a stream is relatively simple, requiring only a few pieces of setup.

1. One must [instantiate an `R5BandwidthDetection` instance](BandwidthDetectionDownloadOnlyTest.swift#L26)
2. One must then [utilize the `checkDownloadSpeed` method](BandwidthDetectionDownloadOnlyTest.swift#L32) of that instance
3. Doing so requires passing in:
	1. The base url (usually the same as the `host` you would provide to your `R5Configuration`)
	2. How long you wish the total bandwidth test to take, in seconds
	3. Callback blocks for the successful and unsuccessful attempts at checking the bandwidth

A simplified example of this would be:

```swift
let detection = R5BandwidthDetection()

detection.checkDownloadSpeed("your-host", forSeconds: 2.5, withSuccess: { (Kbps) in
    print("Download speed is \(Kbps)Kbps\n")
}) { (error) in
    print("There was an error checking your download speed! \(error?.localizedDescription ?? "Unknown error")")
}
```

The rest of this example is based on [SubscribeTest.swift](../Subscribe/) and ensures that a [minimum bandwidth](BandwidthDetectionDownloadOnlyTest.swift#L35) (as [defined by the `tests.plist` file](../tests.plist#L11-12)) is met prior to subscribing to the stream.
