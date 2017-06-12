//
//  SubscribeTest.m
//  R5ProObjectiveCExamples
//
//  Created by David Heimann on 6/12/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

#import "SubscribeTest.h"
#import "Testbed.h"

@interface SubscribeTest ()

@property int current_rotation;

@end

@implementation SubscribeTest

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupDefaultR5VideoViewController];
    
    R5Configuration* config = [self getConfig];
    R5Connection* connection = [[R5Connection alloc] initWithConfig:config];
    
    self.subscribeStream = [[R5Stream alloc] initWithConnection:connection];
    self.subscribeStream.delegate = self;
    self.subscribeStream.client = self;
    
    [self.currentView attachStream:self.subscribeStream];
}

-(void) updateOrientation:(int)value {
    
    if( _current_rotation == value ){
        return;
    }
    
    _current_rotation = value;
    self.currentView.view.layer.transform = CATransform3DMakeRotation((CGFloat)value, 0.0, 0.0, 0.0);
}

-(void) onMetaData:(NSString*)data {
    
    NSArray* props = [data componentsSeparatedByString:@";"];
    for (NSString* keyValue in props) {
        NSArray* kv = [keyValue componentsSeparatedByString:@"="];
        if( [kv[0] isEqualToString:@"orientation"] ){
            NSString* value = kv[1];
            [self updateOrientation: [value intValue] ];
        }
    }
}

@end
