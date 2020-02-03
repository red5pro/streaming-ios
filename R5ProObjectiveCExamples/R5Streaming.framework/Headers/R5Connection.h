//
//  R5Connection.h
//  Red5Pro
//
//  Created by Andy Zupko on 9/16/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "global.h"
#import "R5Configuration.h"


@protocol R5ConnectionDelegate;

/**
 *  @brief The main connection class for R5Pro.  This establishes the connection to the server.  Used by R5Stream as the communication layer.
 */
@interface R5Connection : NSObject

/**
 *  The configuration for this connection
 */
@property (readonly) R5Configuration *config;

/**
 *  The delegate to receive events for this connection. Specifically for Data Only streams.
 */
@property NSObject<R5ConnectionDelegate> *delegate;

/**
 *  The client to receive rpc calls for this connection. Specifically for Data Only streams.
 */
@property NSObject *client;

/**
 *  Initialize the connection with the configuration
 *
 *  @param config The configuration of the connection
 *
 *  @return a new connection
 */
-(id)initWithConfig:(R5Configuration*) configuration;

/**
 * De-initialize the connection.
 */
-(void)invalidate;

/**
 *  Make a connection call RPC to the server
 *
 *  @param method Method name to call
 *  @param returnMethod Return method name.  "void" if no return
 *  @param param  Parameter to send for this method
 */
-(void)call:(NSString*)method withReturn:(NSString*)returnMethod withParam:(NSString*)param;

/*
 *  Start a connection with a remote shared object
 */
-(void)connectToSharedObject:(NSString*)name;

/*
 *  Send a message through the Shared Object interface
 */
-(void)sharedObjectSend:(NSString*)message;

/**
 *  Request to switch the stream received on the current connection.
 * @param app The webapp context the target stream is being streamed in. e.g., "live".
 * @param streamName The new target stream name to request playback.
 */
-(void)switchStream:(NSString*)app name:(NSString*)streamName;

/**
 * Request a connection for data transfers - can't be used if this object is already being used for an A/V stream
 */
-(void)startDataOnlyStream;
-(void)stopDataOnlyStream;

/**
 *  Get the connection context associated with this context
 *
 *  @return A client connection context.
 */
-(client_ctx*)context;


@end

/**
 *  @protocol R5ConnectionDelegate
 *  @brief Delegate for handling R5Stream events
 */
@protocol R5ConnectionDelegate <NSObject>

/**
 *  Status handler for the R5Stream events
 *
 *  @param stream     Stream that has dispatched the event.
 *  @param statusCode Unique status code of the event.
 *  @param msg        A string description of the event.
 *
 *
 *
 *  Status Code     |  Msg
 *  -----------     | ------------
 *  CONNECTED       |   null
 *  DISCONNECTED    |   null
 *  ERROR           |   string message describing error
 *  TIMEOUT         |   null
 *  CLOSE           |   null
 *  START_STREAMING |   null
 *  STOP_STREAMING  |   null
 *  NET_STATUS      |   "NetStream.Play.PublishNotify" - publisher started<br/>"NetStream.Play.UnpublishNotify" - publisher stopped<br/>"NetStream.Play.StreamDry" - Keep Alive while no publisher publishing<br/>"NetStream.Play.InSufficientBW.Audio" - subscriber does not have enough bandwidth to accept audio in stream<br/>"NetStream.Play.InSufficientBW.Video" - subsceiber does not have enough bandwidth to accept video in stream<br/>"NetStream.Play.SufficientBW.Audio" - subscriber has regained enough bandwidth to consume audio<br/>"NetStream.Play.SufficientBW.Video" - subscriber has regained enough bandwidth to consume video
 *  AUDIO_MUTE      |   null
 *  AUDIO_UNMUTE    |   null
 *  VIDEO_MUTE      |   null
 *  VIDEO_UNMUTE    |   null
 *  LICENSE_ERROR   |   null
 *  LICENSE_VALID   |   null
 *  BUFFER_FLUSH_START  |   null
 *  BUFFER_FLUSH_EMPTY  |   null
 *  VIDEO_RENDER_START  |   null
 *
 */
-(void)onR5ConnectionStatus:(R5Connection *)connection withStatus:(int) statusCode withMessage:(NSString*)msg;

@end
