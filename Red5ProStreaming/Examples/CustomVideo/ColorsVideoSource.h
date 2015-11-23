//
//  ColorsVideoSource.h
//  Red5Pro
//
//  Created by Andy Zupko on 11/17/15.
//  Copyright © 2015 Andy Zupko. All rights reserved.
//

#import <R5Streaming/R5Streaming.h>

@interface ColorsVideoSource : R5VideoSource
@property CMTime frameDuration;
@property CMTime PTS;
@property NSTimer *timer;
@end
