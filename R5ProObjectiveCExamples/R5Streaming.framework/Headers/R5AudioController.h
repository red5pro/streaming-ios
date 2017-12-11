//
//  R5AudioController.h
//  red5streaming
//
//  Created by Andy Zupko on 8/28/15.
//  Copyright (c) 2015 Infrared5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sys/stat.h"
#import "global.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVAudioFormat.h>

/**
 Audio Pathway for the R5AudioController.
 */
typedef enum R5AudioControllerMode{
    R5AudioControllerModeStandardIO, //!< Standard RemoteIO - Does not perform and Echo Cancellation
    R5AudioControllerModeEchoCancellation //!< VOIP IO - Performs Echo cancellation
} R5AudioControllerMode;


/**
 *   @brief Controller Object for R5Stream and R5Microphones.  A shared instance is used unless otherwise defined on the object.
 */
@interface R5AudioController : NSObject{


}

/**
 *  The static instance of a single R5AudioController.  Controls all streams by default.
 *
 *  @return a single shared R5AudioController.
 */
+(R5AudioController *)sharedInstance;

/**
 *  Is the R5AudioController currently playing an R5Stream.
 */
@property (readonly) BOOL isPlaying;

/**
 *  Is the R5AudioController currently recording to an R5Stream.
 */
@property (readonly) BOOL isRecording;

/**
 *  Pan (left/right) for audio playback.  -1 to 1 value.
 */
@property (nonatomic) AudioUnitParameterValue pan;

/**
 *  Adjusts the gain of the playback.  0 to 1 value.
 */
@property (nonatomic) AudioUnitParameterValue volume;

//! @cond

/**
 *  Recording sample rate.  Defaults to 16000.  Modifying can cause problems.
 */
@property int RecordSampleRate;

/**
 *  Playback sample rate.  Defaults to 16000.  Modifying can cause problems.
 */
@property int PlaybackSampleRate;

/**
 *  Playback channel count.  Modifying can cause problems.
 */
@property int PlaybackChannelCount;


//! @endcond

/**
 *  Initialize a new R5AudioController
 *
 *  @param mode StandardIO or Echo Cancellation
 *
 *  @return an initialized R5AudioController
 */
-(instancetype)initWithMode:(R5AudioControllerMode)mode;

-(double) currentStreamTime;

@end
