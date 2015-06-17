//
//  PublishExample.m
//  Red5ProStreaming
//
//  Created by Andy Zupko on 6/17/15.
//  Copyright (c) 2015 Infrared5. All rights reserved.
//

#import "PublishExample.h"

@implementation PublishExample


-(void)viewDidAppear:(BOOL)animated{
    
    //set up the publisher - short method
    //self.publish = [self getNewStream:YES];
    
    
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
    config.buffer_time = 1;
    
    //Create a new connection using the configuration above
    R5Connection *connection = [[R5Connection alloc] initWithConfig: config];
    
    //Create our new stream that will utilize that connection
    self.publish = [[R5Stream alloc] initWithConnection:connection];
    
    //Setup our listener to handle events from this stream
    self.publish.delegate = self;
    
    //Get a list of available cameras for this device
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    //Use the last device (front facing)
    AVCaptureDevice *videoDev = [devices lastObject];
    
    //Create an R5Camera with that device and specify the max bitrate to allow
    //Note : This bitrate will not be respected if it is lower than the encoder can go!
    R5Camera *camera = [[R5Camera alloc] initWithDevice:videoDev andBitRate:512];
    
    //Set up the resolution we want this camera to use.  This can only be set before publishing begins
    camera.width   = 640;
    camera.height  = 480;
    
    //Setup the rotation of the video stream.  This is meta data, and is used by the client to rotate the video.  No rotation is done on the publisher.
    camera.orientation = 90;
    
    //Add the camera to the stream
    [self.publish  attachVideo:camera];
    
    //Get our audio capture device
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeAudio];
    
    //Setup a new R5Microphone for streaming audio with that device
    R5Microphone *microphone = [[R5Microphone new] initWithDevice:audioDevice];
    microphone.bitrate = 32;
    
    //Attach the microphone to the stream
    [self.publish attachAudio:microphone];
    
    //setup our R5VideoViewController to display the stream content
    [self setupDefaultR5ViewController];
    
    //attach the R5VideoViewController to our publishing stream
    [self.r5View attachStream:self.publish];
    
    //start publishing!
    [self.publish publish:[self getStreamName:YES] type:R5RecordTypeLive];
    
}

@end
