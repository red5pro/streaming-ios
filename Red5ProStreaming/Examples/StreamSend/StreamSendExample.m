//
//  RPCExample.m
//  Red5ProStreaming
//
//  Created by Andy Zupko on 6/19/15.
//  Copyright (c) 2015 Infrared5. All rights reserved.
//

#import "StreamSendExample.h"


@interface StreamSendExample ()

@end

@implementation StreamSendExample

-(void)viewDidAppear:(BOOL)animated{
    
  
    if([BaseExample getSwapped] == NO){
        
        //WE ARE THE PUBLISHER!
        
        //setup the publish routine
        self.publish = [self getNewStream:PUBLISH];
        
        [self setupDefaultR5ViewController];
        
        [self.r5View attachStream:self.publish];
        
        //set this class to handle RPC response
        self.publish.client = self;
        
        [self.publish publish:[self getStreamName:PUBLISH] type:R5RecordTypeLive];
        
        
        //Button to send RPC
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self
                   action:@selector(sendMessage:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Send" forState:UIControlStateNormal];
        button.backgroundColor = [UIColor whiteColor];
        button.titleLabel.textColor = [UIColor blackColor];

        button.frame = CGRectMake(10.0, 310.0, 160.0, 40.0);
        [self.view addSubview:button];
        
        
    }else{

        //subscribe to the publisher app!
        
        self.subscribe = [self getNewStream:SUBSCRIBE];
        
        [self setupDefaultR5ViewController];
        
        [self.r5View attachStream:self.subscribe];
        
        self.subscribe.client = self;
        
        [self.subscribe play:[self getStreamName:SUBSCRIBE]];
        
    }
    
}

-(void)sendMessage:(id)sender{
    NSLog(@"Sending message!");
    
    //R5Stream send requires parameter to be a mapped key value pairs seperated with ';'
    //key1=value1;key2=value2; ...
    [self.publish send:@"onStreamSend" withParam:@"value=A simple string"];

    
}

-(void)onR5StreamStatus:(R5Stream *)stream withStatus:(int)statusCode withMessage:(NSString *)msg{
    
    //if we error out - reconnect!
    if(stream == self.publish && statusCode == r5_status_start_streaming){
        NSLog(@"Publish stream ready to send RPC");
    }
    
    [super onR5StreamStatus:stream withStatus:statusCode withMessage:msg];
}

/**
 *  R5Stream.client handler
 *
 *  @param value KeyValue map from publisher
 */
-(void)onStreamSend:(NSString*)value{

    //get all key value pairs split
    NSArray *pairs = [value componentsSeparatedByString:@";"];
    for(int i=0;i<pairs.count;i++){
        NSArray *keyvalue = [[pairs objectAtIndex:i] componentsSeparatedByString:@"="];
        if(keyvalue.count > 1){
                NSLog(@"Key: %@\nValue: %@", keyvalue[0], keyvalue[1]);
                [ALToastView toastInView:[[[UIApplication sharedApplication] keyWindow] rootViewController].view withText:[NSString stringWithFormat:@"Stream Send Value: %@", keyvalue[1]]];
            
        }
    }
    
}

@end
