//
//  R5SharedObject.h
//  red5streaming
//
//  Created by David Heimann on 1/13/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "global.h"
#import "R5Configuration.h"
#import "R5Connection.h"

@interface R5SharedObject : NSObject

/**
 *  The value of the remote object
 *  Note - as setProperty doesn't allow for base-level arrays in the JSON, it should always parse as a dictionary
 */
@property (readonly) NSMutableDictionary* data;

/*
 *  The name of the connected shared object
 */
@property (readonly) NSString* name;

/*
 *  The object that is listening to the shared object
 *  Should implement
 */
@property NSObject* client;

/*
 *  Creates a new shared object and connects to
 */
-(id)initWithName:(NSString*)_name connection:(R5Connection*)connection;

/*
 *  Sets the maximum number of times per second to send new data
 */
-(void)setFPS:(double)fps;

/*
 *  Replaces the named property of the object with the specified value, sets specified value dirty
 */
-(void)setProperty:(NSString*)property withValue:(NSObject*)value;

/*
 *  Sets a property to be synced up to the server
 */
-(void)setDirty:(NSString*)property;

/*
 *  Sends a message to everyone watching the Remote Object
 */
-(void)send:(NSString*)call withParams:(NSDictionary*)params;

/*
 *  Closes the connection to the sharedObject
 */
-(void)close;

@end
