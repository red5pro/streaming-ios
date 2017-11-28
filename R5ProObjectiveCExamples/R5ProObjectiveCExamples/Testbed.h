//
//  Testbed.h
//  R5ProObjectiveCExamples
//
//  Created by David Heimann on 6/6/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Testbed : NSObject

+(Testbed *) sharedInstance;
+(NSMutableDictionary *) dictionary;
+(NSArray<NSMutableDictionary *> *) tests;
+(NSMutableDictionary *) parameters;
+(NSMutableDictionary *) localParameters;

+(int) sections;
+(NSUInteger) rowsInSection;
+(NSDictionary *) testAtIndex:(int)index;
+(void) setHost:(NSString *)ip;
+(void) setServerPort:(NSString *)port;
+(void) setStreamName:(NSString *)name;
+(void) setStream1Name:(NSString *)name;
+(void) setStream2Name:(NSString *)name;
+(void) setDebug:(BOOL)on;
+(void) setVideo:(BOOL)on;
+(void) setAudio:(BOOL)on;
+(void) setLocalOverrides:(NSMutableDictionary *)params;
+(void) setLicenseKey:(NSString *)value;

+(id) getParameter:(NSString *)param;

@end
