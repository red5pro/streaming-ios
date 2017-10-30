//
//  R5Connection.h
//  Red5Pro
//
//  Created by Andy Zupko on 9/16/14.
//  Copyright (c) 2014 Andy Zupko. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "global.h"
#import "R5Configuration.h"



/**
 *  @brief The main connection class for R5Pro.  This establishes the connection to the server.  Used by R5Stream as the communication layer.
 */
@interface R5Connection : NSObject

/**
 *  The configuration for this connection
 */
@property (readonly) R5Configuration *config;

/**
 *  Initialize the connection with the configuration
 *
 *  @param config The configuration of the connection
 *
 *  @return a new connection
 */
-(id)initWithConfig:(R5Configuration*) configuration;

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
 *  Get the connection context associated with this context
 *
 *  @return A client connection context.
 */
-(client_ctx*)context;


@end
