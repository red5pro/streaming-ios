//
//  ViewController.m
//  Red5ProStreaming
//
//  Created by Andy Zupko on 6/16/15.
//  Copyright (c) 2015 Infrared5. All rights reserved.
//

#import "ViewController.h"
#import "AdaptiveBitrateExample.h"
#import "PublishExample.h"
#import <R5Streaming/R5Streaming.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    r5_set_log_level(r5_log_level_debug);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onAdaptiveBitrate:(id)sender {
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
    
    AdaptiveBitrateExample *vc = [AdaptiveBitrateExample new];
    vc.view = view;
    
    
    [self.navigationController pushViewController:vc animated:YES];
    
    
    
}

- (IBAction)onPublish:(id)sender {
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
    
    PublishExample *vc = [PublishExample new];
    vc.view = view;
    
    
    [self.navigationController pushViewController:vc animated:YES];
}
@end
