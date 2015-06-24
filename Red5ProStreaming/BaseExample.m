//
//  BaseExample.m
//  Red5ProStreaming
//
//  Created by Andy Zupko on 6/16/15.
//  Copyright (c) 2015 Infrared5. All rights reserved.
//

#import "BaseExample.h"
#import "ALToastView.h"

//simple static to mark whether we shoudl switch stream1 and stream2 names - used for testing 2 devices together
static BOOL _swapped = NO;


@implementation BaseExample


+(void)setSwapped:(BOOL)swapped{
    _swapped = swapped;
}

+(BOOL)getSwapped{
    return _swapped;
}

-(void)viewDidLoad{
    
    
    [self setEdgesForExtendedLayout:UIRectEdgeAll];
    
}


-(R5Stream *) getNewStream: (enum R5StreamType) type{
        
     NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"connection" ofType:@"plist"]];
    
    R5Configuration *config = [[R5Configuration alloc] init];
    config.host = [dict objectForKey:@"domain"];
    config.contextName = [dict objectForKey:@"context"];
    config.port = [(NSNumber *)[dict objectForKey:@"port"] intValue];
    config.protocol = 1;
    config.buffer_time = 1;
    
    R5Connection *connection = [[R5Connection alloc] initWithConfig: config];
    
    R5Stream *stream = [[R5Stream alloc] initWithConnection:connection];
    
    stream.delegate = self;
    
    //attach audio/video to stream if we are publishing!
    if(type == PUBLISH){
       
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        AVCaptureDevice *videoDev = [devices lastObject];
        
        R5Camera *camera = [[R5Camera alloc] initWithDevice:videoDev andBitRate:128];
        
        camera.width   = 320;
        camera.height  = 240;
        
        camera.orientation = 90;
        
        [stream attachVideo:camera];
        
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeAudio];
        
        R5Microphone *microphone = [[R5Microphone new] initWithDevice:audioDevice];
        microphone.bitrate = 32;
        
        [stream attachAudio:microphone];

        
    }

    return stream;
}


-(void) setupDefaultR5ViewController{

    self.r5View = [self getNewViewController:self.view.frame];
    [self addChildViewController:self.r5View];
    [self.view addSubview:self.r5View.view];
    
    //show the camera before we start!
    [self.r5View showPreview:YES];
    
    //show the debug information for the stream
    [self.r5View showDebugInfo:YES];
}

-(R5VideoViewController *) getNewViewController: (CGRect) frame{
    
    UIView *view = [[UIView alloc] initWithFrame: frame];
    R5VideoViewController *viewController = [[R5VideoViewController alloc] init];
    viewController.view = view;
    return viewController;
}


-(NSString*)getStreamName : (enum R5StreamType)type{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"connection" ofType:@"plist"]];

    if(type == PUBLISH || _swapped == YES){
        return [dict objectForKey:@"stream2"];
    }else{
        return [dict objectForKey:@"stream1"];
    }
}

-(void) cleanup{
    
    if(self.publish)
       [self.publish stop];
    
    if(self.subscribe)
       [self.subscribe stop];
}


-(void)onR5StreamStatus:(R5Stream *)stream withStatus:(int)statusCode withMessage:(NSString *)msg{
    
    //Display simple popup  message with the event information
    [ALToastView toastInView:[[[UIApplication sharedApplication] keyWindow] rootViewController].view withText:[NSString stringWithFormat:@"Stream: %s - %@", r5_string_for_status(statusCode), msg]];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [self cleanup];
}


@end
