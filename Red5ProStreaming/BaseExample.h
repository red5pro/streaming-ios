//
//  BaseExample.h
//  Red5ProStreaming
//
//  Created by Andy Zupko on 6/16/15.
//  Copyright (c) 2015 Infrared5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <R5Streaming/R5Streaming.h>


enum R5StreamType{ PUBLISH, SUBSCRIBE };

@interface BaseExample : UIViewController<R5StreamDelegate>

@property R5Stream *subscribe;
@property R5Stream *publish;
@property R5VideoViewController *r5View;

/**
 *  A new connection object populated from connection.plist
 *
 *  @return a new connection
 */
-(R5Stream *) getNewStream: (enum R5StreamType) type;

/**
 *  Get the name of the stream from the connection.plist
 *
 *  @param publishing is this a publish or subscribe stream
 *
 *  @return name for the stream
 */
-(NSString*)getStreamName : (enum R5StreamType)type;

/**
 *  Close all R5Streams
 */
-(void) cleanup;


/**
 *  Get a new R5VideoViewController to display on
 *
 *  @param frame view frame to use
 *
 *  @return View Controller setup
 */
-(R5VideoViewController *) getNewViewController: (CGRect) frame;

/**
 *  Setup the default R5View as a fullscreen view
 */
-(void) setupDefaultR5ViewController;


//swap stream names to test on 2 devices together
+(void)setSwapped:(BOOL)swapped;
+(BOOL)getSwapped;

@end
