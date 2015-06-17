//
//  SubscribeExample.m
//  Red5ProStreaming
//
//  Created by Andy Zupko on 6/17/15.
//  Copyright (c) 2015 Infrared5. All rights reserved.
//

#import "SubscribeExample.h"

@interface SubscribeExample ()

@end

@implementation SubscribeExample

-(void)viewDidAppear:(BOOL)animated{
    
    //set up the subscriber - short method
    //self.subscribe = [self getNewStream:SUBSCRIBE];
    
    
    /*
     *
     Step by step
     *
     */
    
    //Get our connection settings
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"connection" ofType:@"plist"]];
    
    //Setup a configuration object for our connection
    R5Configuration *config = [[R5Configuration alloc] init];
    config.host = [dict objectForKey:@"domain"];
    config.contextName = [dict objectForKey:@"context"];
    config.port = [(NSNumber *)[dict objectForKey:@"port"] intValue];
    config.protocol = 1;
    
    //How long to stream the buffer before beginning playback
    config.buffer_time = 1;
    
    //Create a new connection using the configuration above
    R5Connection *connection = [[R5Connection alloc] initWithConfig: config];
    
    //Create our new stream that will utilize that connection
    self.subscribe  = [[R5Stream alloc] initWithConnection:connection];
    
    //Setup our listener to handle events from this stream
    self.subscribe.delegate = self;
    
    //setup our R5VideoViewController to display the stream content
    [self setupDefaultR5ViewController];
    
    //attach the R5VideoViewController to our publishing stream
    [self.r5View attachStream:self.subscribe];
    
    //start subscribing!!
    [self.subscribe play:[self getStreamName:SUBSCRIBE] ];

    
}

/**
 *  Handle self.subscribe.delegate callbacks
 *
 *  @param stream     stream making callback
 *  @param statusCode code of message
 *  @param msg        addtional context
 */
-(void)onR5StreamStatus:(R5Stream *)stream withStatus:(int)statusCode withMessage:(NSString *)msg{
    
    //pass to super to present toast
    [super onR5StreamStatus:stream withStatus:statusCode withMessage:msg];
}

@end
