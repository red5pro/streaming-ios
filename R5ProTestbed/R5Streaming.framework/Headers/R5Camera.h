//
//  R5Camera.h
//  red5streaming
//
//  Created by Andy Zupko on 10/31/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "R5VideoSource.h"
#import "R5AudioController.h"

/**
 *  @brief R5Camera encapsulates an AVCaptureDevice and provides video data to the R5Stream for publishing
 */
@interface R5Camera : R5VideoSource

@property CMSampleBufferRef currentSampleBuffer;

@property (nonatomic) AVCaptureDevice *device;

/**
 *  Initialize the camera with device and bitrate
 *
 *  @param device  device to capture data from
 *  @param bitRate bits in kbps to stream the data
 *
 *  @return a new R5Camera
 */
-(id)initWithDevice:(AVCaptureDevice*)device andBitRate:(int)bitRate;


@end

/**
 * @param samples   A data object containing the raw audio from the mic
 * @param streamtimeMill    current stream time in milliseconds for timing purposes
 */
typedef void (^AudioModHandle)(NSMutableData*, double);

/**
 *  @brief R5Microphone encapsulates an AVCaptureDevice and provides data to the R5Stream for publishing.
 */
@interface R5Microphone : NSObject

@property AVCaptureDevice *device;  //!< Input device
@property int sampleRate;           //!< sample rate to capture
@property int channels;             //!< number of channels to capture
@property int bitrate;              //!< bitrate in kbps
@property R5AudioController *audioController; //!< Audio Controller for recording.  Defaults to shared instance.
@property AudioModHandle processData; //!< block to handle modifying or replacing raw audio from the microphone

/**
 *  A microphone input for R5Stream
 *
 *  @param device Microphone to use
 *
 *  @return new R5Microphone
 */
-(id)initWithDevice:(AVCaptureDevice*)device;


@end
