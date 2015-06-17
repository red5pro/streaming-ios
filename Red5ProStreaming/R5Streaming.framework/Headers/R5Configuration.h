//
//  R5Configuration.h
//  red5streaming
//
//  Created by Andy Zupko on 11/12/14.
//  Copyright (c) 2014 Andy Zupko. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @brief Configuration object for the R5Stream.
 */
@interface R5Configuration : NSObject

@property int protocol;
@property NSString *host;           //!< Host (IP) to connect too
@property NSString *contextName;    //!< Application/Context name
@property NSString *streamName;     //!< Name of the stream to publish/subscribe too
@property int port;                 //!< Port to connect over

//! @cond
@property NSMutableArray *setup;
@property NSString *sdp_body;
//! @endcond

@property float buffer_time;        //!< Desired buffer time for streaming

@end
