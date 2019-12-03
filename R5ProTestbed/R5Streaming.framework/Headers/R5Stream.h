//
//  R5Stream.h
//  Red5Pro
//
//  Created by Andy Zupko on 9/16/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "global.h"
#import "R5Connection.h"
#import "R5Camera.h"
#import "R5Configuration.h"
#import "R5AudioController.h"
#include <AVFoundation/AVFoundation.h>




@protocol R5StreamDelegate;

/**
 Recording type for publishing
 */
enum R5RecordType{
    R5RecordTypeLive,   //!< No recording
    R5RecordTypeRecord, //!< Record a new file
    R5RecordTypeAppend  //!< Append the recording to an existing recording if available
};

enum R5StreamMode{
    r5_stream_mode_idle,
    r5_stream_mode_streaming,
    r5_stream_mode_publishing

};

extern NSString *const R5RecordVideoBitRateKey;
extern NSString *const R5RecordAudioBitRateKey;
extern NSString *const R5RecordAlbumName;

/**
 *  @brief The main stream class of Red5Pro.  Utilizes the #R5Connection to connect and communicate with a server instance.
 */
@interface R5Stream : NSObject{


}

/**
 *  Audio Controller for Stream playback. Defaults to shared instance.
 */
@property R5AudioController *audioController;


/**
 *  The connection that the stream is communicating with.
 */
@property (readonly) R5Connection *connection;

/**
 *  The stream delegate to receive events for this connection.
 */
@property NSObject<R5StreamDelegate> *delegate;

/**
 *  Client object that will receive all RPC callbacks.
 */
@property NSObject *client;

/**
 * Flag to "mute" audio for Publishing.
 */
@property BOOL pauseAudio;

/**
 * Flag to "mute" video for Publishing.
 */
@property BOOL pauseVideo;

/**
 *  Initialize the stream.  The connection is *not* established.
 *
 *  @param conn The connection to utilize for the stream
 *
 *  @return a new Stream
 */
-(id)initWithConnection:(R5Connection *) conn;

/**
 *  Subscribe to an existing stream
 *
 *  @param streamName name of the stream to subscribe too
 */
-(void)play:(NSString *)streamName;

/**
 *  Publish to a new stream
 *
 *  @param streamName Unique name for this stream
 *  @param type       R5RecordType type of publishing
 *  @li R5RecordTypeLive - No recording
 *  @li R5RecordTypeRecord - Record a new file
 *  @li R5RecordTypeAppend  - Append the recording to an existing recording if available

 */
-(void)publish:(NSString *)streamName type:(enum R5RecordType)type;

/**
 *  Stop all publishing and subscribing on this stream
 */
-(void) stop;

/**
 * Request to empty any queued packets for broadcast.
 */
-(void) emptyPublishQueue;

/**
 *  Get the video preview layer for publising
 *
 *  @return the video preview layer if it exists
 */
- (AVCaptureVideoPreviewLayer*) getPreviewLayer;

/**
 *  Attach an audio input to this stream for publishing
 *
 *  @param microphone The microphone to stream
 */
-(void) attachAudio:(R5Microphone *)microphone;

/**
 *  Attach a video input to this stream for publishing
 *
 *  @param camera The video source to stream
 */
-(void) attachVideo:(R5VideoSource *)camera;

/**
 *  Get the current streaming mode of the stream
 *
 *  @return an R5Stream mode that will be one of the following:
 *  @li r5_stream_mode_idle
 *  @li r5_stream_mode_streaming
 *  @li r5_stream_mode_publishing
 */
-(enum R5StreamMode) mode;

/**
 *  Send a stream RPC to the server.  Only available to publishing streams.
 *
 *  @param methodName name of the method to invoke on the server
 *  @param param      parameter to pass to the server for this message.
 */
-(void)send:(NSString*)methodName withParam:(NSString*)param;

/**
 *  Get the current running stats for this stream
 *
 *  @return an r5_stats object for this stream
 */
-(r5_stats*) getDebugStats;

/**
 *  Get the currently attached video stream
 *
 *  @return the attached video source or nil
 */
-(R5VideoSource *) getVideoSource;

/**
 *  Get the currently attached audio source
 *
 *  @return the attached audio source or nil
 */
-(R5Microphone*) getMicrophone;


/**
 *  Get an image of the current stream
 *
 *  @return a UIImage containing the stream input/output
 */
-(UIImage *) getStreamImage;

/**
 *  Send updated stream meta information
 */
-(void)updateStreamMeta;

/**
 *  Sets a block to receive frame data from the renderer, Use R5VideoView instead where possible
 *  @param listenerBlock The block of code to recieve the frame data
 *
 *  The parameters that the block receives are:
 *  uint8_t*    A pointer to an array of color data in RGB format - three values per pixel.
 *              Note, this pointer is managed by the SDK, freeing it will likely cause problems.
 *  int         The width of the image described by the array.
 *  int         The height of the image described by the array.
 */
-(void)setFrameListener:(void (^)(uint8_t *, int, int))listenerBlock;

/**
 *  Sets a handler to receive and optionally manipulate the audio stream data coming in for playback before sending to output.
 *  @param handlerBlock The block of code to recieve the audio data
 *
 *  The parameters that the block receives are:
 *  uint8_t*    A pointer to an array of samples of raw audio. This serves as both input and output, any modification to the array will modify the audio sent to the speakers.
 *              Note, this pointer is managed by the SDK, freeing it will likely cause problems.
 *  int         The number of samples in the array - each sample is a single uint8 value.
 *  double      The time since the stream began playing audio, in milliseconds.
 */
-(void)setPlaybackAudioHandler:(void (^)(uint8_t *, int, double))handlerBlock;

-(void)recordWithName:(NSString*)fileName;
-(void)recordWithName:(NSString*)fileName withProps:(NSDictionary*)properties;

-(void)endLocalRecord;

/**
 *  Pauses processing of video frames
 */
-(void)deactivate_display;
-(void)activate_display;


@end


/**
 *  @protocol R5StreamDelegate
 *  @brief Delegate for handling R5Stream events
 */
@protocol R5StreamDelegate <NSObject>

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
-(void)onR5StreamStatus:(R5Stream *)stream withStatus:(int) statusCode withMessage:(NSString*)msg;

@end
