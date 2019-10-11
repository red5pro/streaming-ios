//
//  R5AdaptiveBitrateController.h
//  red5streaming
//
//  Created by Andy Zupko on 5/13/15.
//  Copyright (c) 2015 Infrared5. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "R5Camera.h"
#import "R5Stream.h"
#import "global.h"


/**
 * @file
 * @mainpage Adaptive Bitrate Publishing
 *
 * @section intro_sec Setup
 * Attach an #R5AdaptiveBitrateController to any R5Stream to dynamically control the bitrate that is being published by the attached R5VideoSource.

 * 
*\code{.m}
 
R5Stream *stream = ...;
R5AdaptiveBitrateController *controller = [[R5AdaptiveBitrateController alloc] init];
[controller attachToStream:stream];

 *\endcode
 *
 * The #R5Configuration.buffer_time controls how much publishing data is allowed to buffer on the publishing client before the quality is downgraded.  If the buffer is empty, the quality will continue to improve until a balance can be found.
 *
 * @section det_sec Details on Bit Rate
 * The #R5AdaptiveBitrateController uses a default step size of 200 kbps to increase and decrease quality to improve network conditions, while providing the highest quality video possible.  If the maximum bit rate is lower than a 200 kbps step size can support, the step size will equal MAXIMUM_BITRATE / 5;
 
 * MAXIMUM_BITRATE is set to the R5VideoSource.bitrate;  The adaptive bitrate will not go over this value.
 * MINIMUM_BITRATE is set to 16.  The iOS encoder will never reach this bitrate.  In this case it will use the smallest bitrate that is possible for the encoder.  This value will depend on the resolution of the stream.
 * 
 *If network performance is still degraded at the MINIMUM_BITRATE, video will stop sending altogether and only audio will stream.  You can disable this feature by setting R5AdaptiveBitrateController.requireVideo to TRUE;
 */

/**
 *  @brief R5AdaptiveBitrateController allows you to dynamically control the bitrate of the publisher on an R5Stream.  It updates on a 2 second interval.
 */
@interface R5AdaptiveBitrateController : NSObject

    @property BOOL requiresVideo; //!< Require video to be streamed even if network quality is degraded.
    -(id)   attachToStream:(R5Stream *)stream;  //!< Attach the controller to a stream.
    -(void) stop; //!< disable the timer that checks conditions to switch quality of stream.
    -(void) resume; //!< re-enable the time that checks conditions to switch quality of stream.
    -(void) close; //!< disable the adaptive controller.  Bitrate will NOT reset on the R5VideoSource of the stream.

    -(int) getBitrateLevel; //!< Returns the current bitrate level that the ABR is at.
    -(void) setBitrateLevel:(int)value; //!< Specify the current level desired to determine whether to upgrade or downgrade quality when the ABR does its next check.
    -(void) setBitrateLevelAndMaintain:(int)value; //!< Specify the current level desired and disable the timer check. Call :resume to start timer check again.
    -(NSArray *) getBitrateLevelValues; //!< Returns the list of bitrate values for the levels used in determinig quality of stream.
    -(void) setBitrateLevelValues:(NSArray *)values; //!< Explicitly define the set of bitrate levels. USE WITH CAUTION.
    -(void) setUpdateDelay:(double)value; //!< Set update frequency of the controller in seconds

@end
