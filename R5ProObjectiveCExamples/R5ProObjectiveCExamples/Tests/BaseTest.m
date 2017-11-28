//
//  BaseTest.m
//  R5ProObjectiveCExamples
//
//  Created by David Heimann on 6/6/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTest.h"
#import "ALToastView.h"
#import "Testbed.h"

@interface BaseTest ()

@end

@implementation BaseTest

-(id)init{
    return [super initWithNibName:nil bundle:nil];
    _shouldAutorotate = YES;
    _supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    return [super initWithCoder:aDecoder];
    _shouldAutorotate = YES;
    _supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
}

-(void) onR5StreamStatus:(R5Stream *)stream withStatus:(int)statusCode withMessage:(NSString *)msg{
    NSLog(@"Status: %s", r5_string_for_status(statusCode));
    NSString* s = [NSString stringWithFormat:@"Status: %s (%@)", r5_string_for_status(statusCode), msg];
    
    [ALToastView toastInView:self.view withText:s];
}

-(void) closeTest{
    
    NSLog(@"closing view");
    
    if( _publishStream != nil ){
        [_publishStream stop];
    }
    
    if( _subscribeStream != nil ){
        [_subscribeStream stop];
    }
    
    [self removeFromParentViewController];
}

-(R5Configuration*) getConfig{
    R5Configuration* config = [[R5Configuration alloc] init];
    config.host = [Testbed getParameter:@"host"];
    config.port = (int)[[Testbed getParameter:@"port"] integerValue];
    config.contextName = [Testbed getParameter:@"context"];
    config.protocol = 1;
    config.buffer_time = [[Testbed getParameter:@"buffer_time"] floatValue];
    config.licenseKey = [Testbed getParameter:@"license_key"];
    
    return config;
}

-(void) setupPublisher:(R5Connection*)connection{
    _publishStream = [[R5Stream alloc] initWithConnection:connection];
    _publishStream.delegate = self;
    
    if( [[Testbed getParameter:@"video_on"] boolValue] ){
        // Attach the video from camera to stream
        AVCaptureDevice *videoDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] lastObject];
        
        R5Camera *camera = [ [R5Camera alloc] initWithDevice:videoDevice andBitRate:[[Testbed getParameter:@"bitrate"] intValue] ];
        
        camera.width = [[Testbed getParameter:@"camera_width"] intValue];
        camera.height = [[Testbed getParameter:@"camera_height"] intValue];
        camera.orientation = 90;
        [self.publishStream attachVideo:camera];
    }
    if ( [[Testbed getParameter:@"audio_on"] boolValue] ) {
        AVCaptureDevice* audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        R5Microphone* microphone = [[R5Microphone alloc] initWithDevice:audioDevice];
        microphone.bitrate = 32;
        microphone.device = audioDevice;
        NSLog(@"Got device %@", audioDevice);
        [_publishStream attachAudio:microphone];
    }
}

-(R5VideoViewController*) setupDefaultR5VideoViewController{
    
    R5VideoViewController* r5View = [self getNewR5VideoViewController:[self view].frame];
    [self addChildViewController:r5View];
    
    [[self view] addSubview:r5View.view];
    [r5View setFrame:[self view].bounds];
    
    [r5View showPreview:YES];
    [r5View showDebugInfo:[[Testbed getParameter:@"debug_view"] boolValue]];
    
    _currentView = r5View;
    
    return _currentView;
}

-(R5VideoViewController*) getNewR5VideoViewController:(CGRect)rect{
    
    UIView* view = [[UIView alloc] initWithFrame:rect];
    
    R5VideoViewController* r5View = [[R5VideoViewController alloc] init];
    r5View.view = view;
    
    return r5View;
}

-(void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if(_currentView != nil){
        [_currentView setFrame: [self view].frame];
    }
}

-(void) viewDidLoad{
    [super viewDidLoad];
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted){
        
    }];
    
    r5_set_log_level(r5_log_level_debug);
    
    [self view].autoresizesSubviews = NO;
}

-(void) viewDidAppear:(BOOL)animated{
    
    //this is just to have a white background to the example
    UIView* backView = [[UIView alloc] initWithFrame:[self view].frame];
    backView.backgroundColor = [UIColor whiteColor];
    [[self view] addSubview:backView];
}

@end
