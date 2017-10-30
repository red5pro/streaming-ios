//
//  R5BandwidthDetection.h
//  red5streaming
//
//  Created by Kyle Kellogg on 7/24/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "global.h"
#import "R5BandwidthURLConnection.h"

typedef void (^DownloadSuccessHandler)(int speedInKbitsPerSecond);
typedef void (^DownloadFailureHandler)(NSError *error);
typedef void (^CheckSpeedsSuccessHandler)(NSDictionary *speedDict);
typedef void (^CheckSpeedsErrorHandler)(NSError *error);

@interface R5BandwidthDetection : NSObject<NSURLConnectionDataDelegate> {
    NSTimeInterval then;
    long long totalBits;
    int totalRequests;
    int errorRequests;
    NSMutableArray *pending;
    NSMutableArray *data;
    NSString *urlString;
    DownloadSuccessHandler successCb;
    DownloadFailureHandler failureCb;
}

- (void) checkDownloadSpeed:(NSString *)withBaseURL forSeconds:(double)seconds withSuccess:(DownloadSuccessHandler)success andFailure:(DownloadFailureHandler)failure;
- (void) checkUploadSpeed:(NSString *)withBaseURL forSeconds:(double)seconds withSuccess:(DownloadSuccessHandler)success andFailure:(DownloadFailureHandler)failure;
- (void) checkSpeeds:(NSString *)withBaseURL forSeconds:(double)seconds withSuccess:(CheckSpeedsSuccessHandler)success andFailure:(CheckSpeedsErrorHandler)failure;

@end
