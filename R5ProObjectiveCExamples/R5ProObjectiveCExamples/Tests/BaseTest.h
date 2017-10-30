//
//  BaseTest.h
//  R5ProObjectiveCExamples
//
//  Created by David Heimann on 6/6/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <R5Streaming/R5Streaming.h>

@interface BaseTest : UIViewController <R5StreamDelegate>

@property(nonatomic, readonly) BOOL shouldAutorotate;
@property(nonatomic, readonly) UIInterfaceOrientationMask supportedInterfaceOrientations;

@property R5VideoViewController* currentView;
@property R5Stream* publishStream;
@property R5Stream* subscribeStream;

-(void) closeTest;
-(R5Configuration*) getConfig;
-(void) setupPublisher:(R5Connection*)connection;
-(R5VideoViewController*) setupDefaultR5VideoViewController;
-(R5VideoViewController*) getNewR5VideoViewController:(CGRect)rect;

@end
