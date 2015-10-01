
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AVFoundation/AVAssetWriter.h"
#import "AVFoundation/AVAssetWriterInput.h"
#import "AVFoundation/AVMediaFormat.h"
#import "AVFoundation/AVVideoSettings.h"
#import "R5Camera.h"

typedef int (^encoder_handler_t)(NSArray* data, double pts);
typedef int (^param_handler_t)(NSData* params);

@interface R5AACEncoder : NSObject{

    double frameCount;

}


- (void) encodeWithBlock:(encoder_handler_t) block onParams: (param_handler_t) paramsHandler;

- (void) shutdown;

+ (R5AACEncoder*) encoderForMicrophone:(R5Microphone*)microphone;

-(void)processAudio:(AudioBufferList*)bufferList;
@property R5Microphone *microphone;
@property int sampleRate;
@property int channels;
@property int bitrate;
@property dispatch_queue_t encoderQueue;
@end

