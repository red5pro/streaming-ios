//
//  R5Configuration.h
//  red5streaming
//
//  Created by Andy Zupko on 11/12/14.
//  Copyright (c) 2014 Andy Zupko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "global.h"
/**
 *  @brief Configuration object for the R5Stream.
 */
@interface R5Configuration : NSObject

@property int protocol;
@property NSString *host;           //!< Host (IP) to connect too
@property NSString *contextName;    //!< Application/Context name
@property NSString *streamName;     //!< Name of the stream to publish/subscribe too
@property int port;                 //!< Port to connect over
@property NSString *parameters;     //!< Custom properties for connection.  ';' delimited list of values (ex: "val1;val2;val3;").   Must be set prior to connection being established.
@property float stream_buffer_time; //!< Buffer time request for server buffer time.  Server will start dropping packets after this amount of buffered data has been reached.  Subscriber only.

@property NSString *licenseKey;     //!< SDK License Key
@property NSString *bundleID;       //!< Bundle Identifier, unique for license purposes an App Store requirements.

//! @cond
@property NSMutableArray *setup;
@property NSString *sdp_body;
@property client_ctx *client;
//! @endcond



@property float buffer_time;        //!< Desired buffer time for streaming

@end
