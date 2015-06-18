//
//  AutoReconnectExample.m
//  Red5ProStreaming
//
//  Created by Andy Zupko on 6/18/15.
//  Copyright (c) 2015 Infrared5. All rights reserved.
//

#import "AutoReconnectExample.h"

@interface AutoReconnectExample ()
@property NSTimer *timer;
@end

@implementation AutoReconnectExample

-(void)viewDidAppear:(BOOL)animated{
    
    //setup our R5VideoViewController to display the stream content
    [self setupDefaultR5ViewController];
    
    [self startSubscribe];

}

-(void) startSubscribe{
    
    //set up the subscriber - short method
    self.subscribe = [self getNewStream:SUBSCRIBE];
   
    //attach the R5VideoViewController to our publishing stream
    [self.r5View attachStream:self.subscribe];
    
    //start the subscriber!
    [self.subscribe play:[self getStreamName:SUBSCRIBE]];
    
}

-(void)onR5StreamStatus:(R5Stream *)stream withStatus:(int)statusCode withMessage:(NSString *)msg{

    //if we error out - reconnect!
    if(statusCode == r5_status_connection_error){
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(reconnect:) userInfo:nil repeats:NO];
    }
    
    [super onR5StreamStatus:stream withStatus:statusCode withMessage:msg];
}

-(void)reconnect:(NSTimer*)timer{
    [self startSubscribe];
}


-(void) viewWillDisappear:(BOOL)animated{

    //cancel the timer
    if(self.timer != nil){
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
