# Subscriber Aspect Ratio

`R5VideoViewController.scaleMode` controls the display mode of the content that is being pushed to it. Depending on the value the content will scale to the apropriate fill value. 

### Example Code

- ***[BaseTest.swift](../BaseTest.swift)***
- ***[SubscribeAspectRatioTest.swift](SubscribeAspectRatioTest.swift)***

## Running the example

Begin by publishing to **stream1** from a second device.  **stream1** is the default stream1 name that is used by this example.

Touch the screen at any time while streaming to change the scale mode, affecting how the stream is display on the user's end.

## Using scaleMode

R5VideoViewController.scaleMode has 3 potential enum values.

```sh
r5_scale_to_fill: scale to fill and maintain aspect ratio (cropping will occur)
r5_scale_to_fit: scale to fit inside view (letterboxing will occur)
r5_scale_fill: scale to fill view (will not respect aspect ratio of video)
```

By default, this value is `r5_scale_to_fill` This example handles scalemode by raw value in order to cycle through its values when it receives a tap.

```Swift
var nextMode = (currentView?.scaleMode.rawValue)! + 1;
//A value of 3 or larger won't parse correctly to the enum, so it's reset to 0
if(nextMode == 3){
	nextMode = 0;
}

currentView?.scaleMode = r5_scale_mode(nextMode);
```

[SubscribeAspectRatioTest.swift #39](SubscribeAspectRatioTest.swift#L39)