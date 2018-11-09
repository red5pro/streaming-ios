//
//  fileWriter.h
//  red5streaming
//
//  Created by David Heimann on 5/16/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "global.h"

@interface FileWriter : NSObject

@property (readonly) NSString *fileName;
@property (readonly) int fileCount;
@property BOOL active;

-(id)initWithFileName:(NSString*)fileName properties:(NSDictionary*)props;
-(id)initWithFileName:(NSString*)fileName properties:(NSDictionary*)props withVideo:(BOOL)vidFlag withAduio:(BOOL)audFlag;

-(void)specifySaveAlbum:(NSString*)album;

-(void)writeFrame:(CMSampleBufferRef)sampleBuffer;
-(void)writeAudio:(CMSampleBufferRef)sampleBuffer;
-(void)writeAudio:(NSData*)data withTime:(double)pts andRate:(int)rate;
-(void)writeAudioBuffer:(AudioBufferList*)data withTime:(double)pts andRate:(int)rate;

-(void)finish:(BOOL)saveRecording;

@end
