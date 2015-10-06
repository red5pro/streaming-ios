//
//  R5AudioController.h
//  red5streaming
//
//  Created by Andy Zupko on 8/28/15.
//  Copyright (c) 2015 Andy Zupko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sys/stat.h"
#import "global.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVAudioFormat.h>

typedef enum R5AudioControllerMode{
    R5AudioControllerModeStandardIO,
    R5AudioControllerModeEchoCancellation
} R5AudioControllerMode;


@interface R5AudioController : NSObject{
    AudioStreamBasicDescription audioFormat;
    AudioStreamBasicDescription streamInAudioFormat;
    double frameCount;
    AudioComponentInstance audioUnit;
    
    AVAudioFormat *mAudioFormat;
    
    AUGraph   mGraph;
    AudioUnit mMixer;
    AudioUnit mOutput;
   
}

+(R5AudioController *)sharedInstance;

@property (readonly) AudioComponentInstance audioUnit
;
@property (readonly) AudioStreamBasicDescription audioFormat;
@property (readonly) AudioStreamBasicDescription streamInAudioFormat;
@property (readonly) BOOL isPlaying;
@property (readonly) BOOL isRecording;

@property (nonatomic) AudioUnitParameterValue pan;
@property (nonatomic) AudioUnitParameterValue volume;



-(instancetype)initWithMode:(R5AudioControllerMode)mode;

//startRecording with passback to encoder
-(void)startRecording:(NSObject *)encoder;
-(void)startPlayback:(NSObject *)stream;

-(void)stopPlayback;
-(void)stopRecording;


@end
