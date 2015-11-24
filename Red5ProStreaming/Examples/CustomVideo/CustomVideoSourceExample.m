//
//  CustomVideoSourceExample.m
//  Red5ProStreaming
//
//  Created by Andy Zupko on 11/23/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

#import "CustomVideoSourceExample.h"
#import "ColorsVideoSource.h"

@interface CustomVideoSourceExample ()

@end

@implementation CustomVideoSourceExample

-(void)viewDidAppear:(BOOL)animated{
    
    //set high level of logging
    r5_set_log_level(r5_log_level_debug);
    
    
    //get custom parameters for the connecion from connection.plist
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"connection" ofType:@"plist"]];
    
    R5Configuration *config = [[R5Configuration alloc] init];
    config.host = [dict objectForKey:@"domain"];
    config.contextName = [dict objectForKey:@"context"];
    config.port = [(NSNumber *)[dict objectForKey:@"port"] intValue];
    config.protocol = 1;
    config.buffer_time = 1;
    
    //initialize the connection
    R5Connection *connection = [[R5Connection alloc] initWithConfig: config];
    
    self.publish = [[R5Stream alloc] initWithConnection:connection];
    
    self.publish.delegate = self;
    
    
    //create a new video source which will pump video to the stream
    ColorsVideoSource *customVideoSource = [ColorsVideoSource new];
    
    [self.publish attachVideo:customVideoSource];

    
    //setup a standard microphone input
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeAudio];
    
    R5Microphone *microphone = [[R5Microphone new] initWithDevice:audioDevice];
    microphone.bitrate = 32;
    
    [self.publish attachAudio:microphone];

    
      //start publishing!
    [self.publish publish:[self getStreamName:PUBLISH] type:R5RecordTypeLive];
    
}

-(void)onR5StreamStatus:(R5Stream *)stream withStatus:(int)statusCode withMessage:(NSString *)msg{
    
    [super onR5StreamStatus:stream withStatus:statusCode withMessage:msg];
    
}


@end
