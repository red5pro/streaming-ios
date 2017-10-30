//
//  R5VideoSource.h
//  red5streaming
//
//  Created by Andy Zupko on 2/4/15.
//  Copyright (c) 2015 Infrared5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AVEncoder.h"
#import "FileWriter.h"

typedef int (^source_handler_t)(NSArray* data, double pts);
typedef int (^source_param_handler_t)(NSData* params);


/**
 *  @brief The video source provides all video frames to the encoder for transmission over the socket.  
 *
 *  A video source expects 
 */
@interface R5VideoSource : NSObject
@property int width;            //!< Desired width of the video source (subject to hardware)
@property int height;           //!< Desired height of the video source (subject to hardware)
@property int bitrate;          //!< Bitrate in kbps of the video stream
@property int orientation;      //!< Orientation of presentation. @note  Video is rotated by the streaming software and NOT in the encoding.  This is a meta flag only.

@property int fps;                  //!< Frame rate to record at
@property AVEncoder *encoder;//!< Hardware encoder set by the VideoSource.  Pass frames to the encoder to continue to socket
@property FileWriter *writer;

@property BOOL adaptiveBitRate;

//@property BOOL pauseEncoding;


@property AVCaptureVideoDataOutput *output; //!< Output path for the encoded data


/**
 *  Start capturing and encoding video
 */
-(void)startVideoCapture;


/**
 *  Stop capturing and encoding video
 */
-(void)stopVideoCapture;


/**
 *  Setup the encoding handler.  Will pass the handles to the encoder for processing the data
 *
 *  @param block         data and timestamp of the frame to process
 *  @param paramsHandler parameters of the encoding used for setting up the codec
 */
- (void) encodeWithBlock:(source_handler_t) block onParams: (source_param_handler_t) paramsHandler;

/**
 *  Records captured data to local device
 */
-(void)attatchRecorder:(FileWriter*)fileWriter;

-(void)detatchRecorder;

/**
 *  A dictionary formatted with the following keys:
 *  @li R5VideoWidthkey - NSNumber (int)
 *  @li R5VideoHeightKey - NSNumber (int)
 *  @li R5VideoBitRateKey - NSNumber (int)
 *  @li R5VideoOrientationKey - NSNumber (float)
 *  @li R5VideoAdaptiveBitRateKey - NSString ( "YES" | "NO" )
 *
 *  @return a properly formatted dictionary with all keys set
 */
-(NSDictionary *) getSourceProperties;

/**
 *  Initialize the VideoSource with the appropriate inputs
 *
 *  @param session Session to initialize
 */
-(void)configureSession:(AVCaptureSession*)session;

/**
 *  Release the session and stop all session activities
 *
 *  @param session Session to stop
 */


-(void)releaseSession:(AVCaptureSession*)session;


-(void)updateEncoder;

@end
