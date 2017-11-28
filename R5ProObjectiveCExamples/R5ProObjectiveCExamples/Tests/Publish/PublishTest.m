//
//  PublishTest.m
//  R5ProObjectiveCExamples
//
//  Created by David Heimann on 6/6/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

#import "PublishTest.h"
#import "Testbed.h"

@interface PublishTest ()

@end

@implementation PublishTest

-(void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        
    }];
    
    [self setupDefaultR5VideoViewController];
    
    R5Configuration* config = [self getConfig];
    R5Connection* connection = [[R5Connection alloc] initWithConfig:config];
    
    [self setupPublisher:connection];
    
    [self.currentView attachStream:self.publishStream];
    
    [self.publishStream publish:[Testbed getParameter:@"stream1"] type:R5RecordTypeRecord];
}

@end
