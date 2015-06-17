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





typedef int (^encoder_handler_t)(NSArray* data, double pts);
typedef int (^param_handler_t)(NSData* params);

@interface AVEncoder : NSObject

+(AVEncoder*)encoderWithParams:(NSDictionary*)params;

- (void) encodeWithBlock:(encoder_handler_t) block onParams: (param_handler_t) paramsHandler;

-(void) updateParams:(NSDictionary *)params;

- (void) encodeFrame:(CMSampleBufferRef) sampleBuffer ofType:(int)media_type;
- (NSData*) getConfigData;
- (void) shutdown;


@property (readonly, atomic) int bitspersecond;

@end

