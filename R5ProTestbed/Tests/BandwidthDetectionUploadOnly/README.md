# Bandwidth Detection (Upload) with Red5 Pro

This example shows how to easily detect upload bandwidth with Red5 Pro prior to publishing a stream.

## Example Code

* **_[BaseTest.swift](../BaseTest.swift)_**
* **_[BandwidthDetectionUploadOnlyTest.swift](BandwidthDetectionUploadOnlyTest.swift)_**

## How to Check Bandwidth

Checking the upload bandwidth prior to publishing a stream is relatively simple, requiring only a few pieces of setup.

1. One must [instantiate an `R5BandwidthDetection` instance](BandwidthDetectionUploadOnlyTest.swift#L30)
2. One must then [utilize the `checkUploadSpeed` method](BandwidthDetectionUploadOnlyTest.swift#L36) of that instance
3. Doing so requires passing in:
	1. The base url (usually the same as the `host` you would provide to your `R5Configuration`)
	2. How long you wish the total bandwidth test to take, in seconds
	3. Callback blocks for the successful and unsuccessful attempts at checking the bandwidth

A simplified example of this would be:

```swift
let detection = R5BandwidthDetection()

detection.checkUploadSpeed("your-host", forSeconds: 2.5, withSuccess: { (Kbps) in
    print("Upload speed is \(Kbps)Kbps\n")
}) { (error) in
    print("There was an error checking your download speed! \(error?.localizedDescription ?? "Unknown error")")
}
```

The rest of this example is based on [PublishTest.swift](../Publish/) and ensures that a [minimum bandwidth](BandwidthDetectionUploadOnlyTest.swift#L39) (as [defined by the `tests.plist` file](../tests.plist#L11-12)) is met prior to publishing to the stream.
