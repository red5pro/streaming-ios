//
//  AdaptiveBitrateExample.m
//  Red5ProStreaming
//
//  Created by Andy Zupko on 6/16/15.
//  Copyright (c) 2015 Infrared5. All rights reserved.
//

#import "AdaptiveBitrateExample.h"

@implementation AdaptiveBitrateExample

-(void)viewDidAppear:(BOOL)animated{

    //set up the publisher
    self.publish = [self getNewStream:PUBLISH];
 
    //setup our R5VideoViewController to display the stream content
    [self setupDefaultR5ViewController];
    
    //attach the R5VideoViewController to our publishing stream
    [self.r5View attachStream:self.publish];
    
    //before we attach our bitrate controller, we can set our bitrate to be a higher quality
    //this can be set directly on the R5Camera in BaseExample::getNewStream as well.
    [self.publish getVideoSource].bitrate = 768;
    
    //setup the adaptive bitrate!
    R5AdaptiveBitrateController *adaptor = [R5AdaptiveBitrateController new];
    [adaptor attachToStream:self.publish];
    
    //If you do not require video to be published, video may be dropped if network conditions cannot handle the lowest quality video setting.
    //If you DO  require video, you can use this flag to force it to stay on.  WARNING: your video may start artifacting or cause other delays in the stream with this option forced.
    adaptor.requiresVideo = YES;
    
    //start publishing!
    [self.publish publish:[self getStreamName:PUBLISH] type:R5RecordTypeLive];
    
}

-(void)onR5StreamStatus:(R5Stream *)stream withStatus:(int)statusCode withMessage:(NSString *)msg{

    [super onR5StreamStatus:stream withStatus:statusCode withMessage:msg];
    
}

-(void)viewDidDisappear:(BOOL)animated{
 
    [self cleanup];
}

@end
