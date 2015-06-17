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
#import "SubscribeExample.h"
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


-(void) showExample : (UIViewController*)viewController{
    
 
     NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"connection" ofType:@"plist"]];
    
    if([[dict objectForKey:@"domain"] isEqualToString:@"0.0.0.0"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Server!" message:@"Set the domain in your connection.plist!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;

    }
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
    viewController.view = view;
    
    [self.navigationController pushViewController:viewController animated:YES];

}



- (IBAction)onAdaptiveBitrate:(id)sender {
    
    [self showExample:[AdaptiveBitrateExample new]];
    
        
}

- (IBAction)onSubscribe:(id)sender {
    
    [self showExample:[SubscribeExample new]];
    
}

- (IBAction)onPublish:(id)sender {
    
   [self showExample:[PublishExample new]];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
}

@end
