//
//  Testbed.m
//  R5ProObjectiveCExamples
//
//  Created by David Heimann on 6/6/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Testbed.h"

@interface Testbed ()

@end

static Testbed* sharedInstance;
static NSMutableDictionary* dictionary;
static NSMutableArray<NSMutableDictionary*>* tests;
static NSMutableDictionary* parameters;
static NSMutableDictionary* localParameters;

@implementation Testbed

+(Testbed *) sharedInstance{
    if(sharedInstance == nil){
        sharedInstance = [[Testbed alloc] init];
        [sharedInstance loadTests];
    }
    return sharedInstance;
}

+(NSMutableDictionary *) dictionary{
    return dictionary;
}

+(NSArray<NSMutableDictionary *> *) tests{
    return tests;
}

+(NSMutableDictionary *) parameters{
    return parameters;
}

+(NSMutableDictionary *) localParameters{
    return localParameters;
}


+(int) sections{
    return 1;
}

+(NSUInteger) rowsInSection{
    return tests.count;
}

+(NSDictionary *) testAtIndex:(int)index{
    return tests[index];
}

+(void) setHost:(NSString *)ip{
    parameters[@"host"] = ip;
}

+(void) setServerPort:(NSString *)port;{
    parameters[@"server_port"] = port;
}

+(void) setStreamName:(NSString *)name{
    parameters[@"stream1"] = name;
}

+(void) setStream1Name:(NSString *)name{
    parameters[@"stream1"] = name;
}

+(void) setStream2Name:(NSString *)name{
    parameters[@"stream2"] = name;
}

+(void) setDebug:(BOOL)on{
    parameters[@"debug_view"] = [NSNumber numberWithBool:on];
}

+(void) setVideo:(BOOL)on{
    parameters[@"video_on"] = [NSNumber numberWithBool:on];
}

+(void) setAudio:(BOOL)on{
    parameters[@"audio_on"] = [NSNumber numberWithBool:on];
}

+(void) setLocalOverrides:(NSMutableDictionary *)params{
    localParameters = params;
}

+(void) setLicenseKey:(NSString *)value{
    parameters[@"license_key"] = value;
}


+(id) getParameter:(NSString *)param{
    
    if(localParameters != nil){
        if(localParameters[param] != nil){
            return localParameters[param];
        }
    }
    
    return parameters[param];
}

-(void) loadTests{
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"tests" ofType:@"plist"];
    
    dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    tests = [[NSMutableArray alloc] init];
    
    for (id key in dictionary[@"Tests"]) {
        [tests addObject:dictionary[@"Tests"][key]];
    }
    
    [tests sortUsingComparator:^NSComparisonResult(NSMutableDictionary* dic1, NSMutableDictionary* dic2){
        
        if( [(NSString*)dic1[@"name"] isEqualToString:@"Home"] ){
            return NSOrderedAscending;
        }
        if( [(NSString*)dic2[@"name"] isEqualToString:@"Home"] ){
            return NSOrderedDescending;
        }
        
        return [(NSString*)dic1[@"name"] compare:(NSString*)dic2[@"name"]];
    }];
    
    parameters = dictionary[@"GlobalProperties"];
    
}

@end
