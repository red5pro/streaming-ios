//
//  TwoWayVideoChatExample.m
//  Red5ProStreaming
//
//  Created by Andy Zupko on 6/18/15.
//  Copyright (c) 2015 Infrared5. All rights reserved.
//

#import "TwoWayVideoChatExample.h"

@interface TwoWayVideoChatExample ()

@end

@implementation TwoWayVideoChatExample

-(void)viewDidAppear:(BOOL)animated{
    
    //setup the publish routine
    self.publish = [self getNewStream:PUBLISH];
    [self setupDefaultR5ViewController];
    
    [self.r5View attachStream:self.publish];
    //set this class to handle RPC response
    self.publish.client = self;
    
    [self.publish publish:[self getStreamName:PUBLISH] type:R5RecordTypeLive];


}


-(void)onR5StreamStatus:(R5Stream *)stream withStatus:(int)statusCode withMessage:(NSString *)msg{
    
    if(stream == self.publish){
        
        if(statusCode == r5_status_start_streaming){
            
            //we have started streaming successfully!!!
            NSLog(@"started streaming!");
            //call out to get our new stream
            [self.publish.connection call:@"streams.getLiveStreams"withReturn:@"onGetLiveStreams"  withParam:@""];
        }
    }
}

-(void)onGetLiveStreams:(NSString *)streams{
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
