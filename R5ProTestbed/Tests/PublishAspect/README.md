# Publish Aspect Ratio

`R5VideoViewController.scaleMode` controls the display mode of the content that is being pushed to it. Depending on the value the content will scale to the appropriate fill value.

### Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[PublishAspectTest.swift](PublishAspectTest.swift)***

## Running the example

Touch the screen at any time while streaming to rotate the video source by 90 degrees. It's sugested that you verify this change with a separate device.

## Using scaleMode

`R5VideoViewController.scaleMode` has 3 potential enum values.

```sh
r5_scale_to_fill: scale to fill and maintain aspect ratio (cropping will occur)
r5_scale_to_fit: scale to fit inside view (letterboxing will occur)
r5_scale_fill: scale to fill view (will not respect aspect ratio of video)
```

By default, this value is `r5_scale_to_fill` and the android SDK handles this enum through raw int value (0,1,2) This example cycles through these values when it receives a tap.

```swift
@objc func handleSingleTap(recognizer : UITapGestureRecognizer) {
    var nextMode = (currentView?.scaleMode.rawValue)! + 1;
    if(nextMode == 3){
        nextMode = 0;
    }
    currentView?.scaleMode = r5_scale_mode(nextMode);
}
```

[PublishAspectTest.swift #50](PublishAspectTest.swift#L50)