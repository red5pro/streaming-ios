//
//  AVEncoder.h
//  Encoder Demo
//
//  Created by Geraint Davies on 14/01/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//



#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "sys/stat.h"
#import "global.h"




typedef int (^encoder_handler_t)(NSArray* data, double pts);
typedef int (^param_handler_t)(NSData* params);

@interface AVEncoder : NSObject


@property double lastPTS;

+(AVEncoder*)encoderWithParams:(NSDictionary*)params;

- (void) encodeWithBlock:(encoder_handler_t) block onParams: (param_handler_t) paramsHandler;

-(void) updateParams:(NSDictionary *)params;

/**
 *  Encode a CMSampleBuffer to streaming format to send over R5Stream
 *
 *  @param sampleBuffer Sample buffer with correctly set timestamp.\n
     Contains an CVImageBufferRef for media_type r5_media_type_video (from camera input).\n
     Contains a CVPixelBufferRef for media_type r5_media_type_video_custom (for rgb or other pixel formats).\n
 *  @param media_type   Type of media that is going to be encoded.\n
    Can be r5_media_type_video or r5_media_type_video_custom
 */
- (void) encodeFrame:(CMSampleBufferRef) sampleBuffer ofType:(r5_media_type) media_type;


- (NSData*) getConfigData;
- (void) shutdown;


@property (readonly, atomic) int bitspersecond;

@end

