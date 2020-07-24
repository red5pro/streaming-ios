//
//  global.h
//  Red5Pro
//
//  Created by Andy Zupko on 9/15/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#ifndef Red5Pro_global_h
#define Red5Pro_global_h

#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>
#ifdef IS_IOS
#include <pthread.h>
#endif

#define STRINGIFY_(s) #s
#define STRINGIFY(s) STRINGIFY_(s)

#define R5PRO_MAJOR_VERSION         7
#define R5PRO_MINOR_VERSION         2
#define R5PRO_REVISION              0
#define R5PRO_BUILD                 0


#define R5PRO_VERSION               STRINGIFY(R5PRO_MAJOR_VERSION.R5PRO_MINOR_VERSION.R5PRO_REVISION.R5PRO_BUILD)
#define R5PRO_VERSION_ISRELEASE     0
#define R5PRO_VERSION_CHECK(maj, min) ((maj==MYLIB_MAJOR_VERSION) && (min<=MYLIB_MINOR_VERSION))

#define SEC_TO_NANO 1e9
#define SEC_TO_MS 1e3

#define SW_DECODE_YUV               1

#if defined(__APPLE__) && defined(__MACH__)
/* Apple OSX and iOS (Darwin). ------------------------------ */
#include <TargetConditionals.h>
#if TARGET_IPHONE_SIMULATOR == 1
/* iOS in Xcode simulator */

#elif TARGET_OS_IPHONE == 1
/* iOS on iPhone, iPad, etc. */

#elif TARGET_OS_MAC == 1
/* OSX */

#endif
#endif

#if TARGET_OS_IPHONE == 1
#define LOG(...) fprintf(stdout, __VA_ARGS__);
#define LOGD(M, ...) if(r5_get_log_level() <= (int)r5_log_level_debug) fprintf(stderr, "[R5 DEBUG]" M "\n", ##__VA_ARGS__)
#define LOGI(M, ...) if(r5_get_log_level() <= (int)r5_log_level_info) fprintf(stderr,  "[R5 INFO] " M "\n", ##__VA_ARGS__)
#define LOGW(M, ...) if(r5_get_log_level() <= (int)r5_log_level_warn) fprintf(stderr,  "[R5 WARNING] " M "\n", ##__VA_ARGS__);
#define LOGE(M, ...) if(r5_get_log_level() <= (int)r5_log_level_error) fprintf(stderr, "[R5 ERROR] " M "\n", ##__VA_ARGS__);

#else
#include <android/log.h>
#define LOG(...) __android_log_print(ANDROID_LOG_INFO, "r5pro", __VA_ARGS__);
#define LOGD(M, ...) if(r5_get_log_level() <= (int)r5_log_level_debug) LOG(M, ##__VA_ARGS__)
#define LOGI(M, ...) if(r5_get_log_level() <= (int)r5_log_level_info) LOG( M, ##__VA_ARGS__)
#define LOGW(M, ...) if(r5_get_log_level() <= (int)r5_log_level_warn) LOG( M, ##__VA_ARGS__);
#define LOGE(M, ...) if(r5_get_log_level() <= (int)r5_log_level_error) LOG(M, ##__VA_ARGS__);
#endif

#define check_mem(A) check((A), "Out of memory.")

/*!
    \defgroup Global
        Public enumeration types and utility functions
*/

    /**
      \ingroup Global
     * Logging level for R5 Pro API
     */
    enum r5_log_level{
        r5_log_level_debug,
        r5_log_level_info,
        r5_log_level_warn,
        r5_log_level_error
    };

    /**
      \ingroup Global
     * Status code for an R5Stream/R5Connection
     */
    enum r5_status {
        r5_status_connected,            //!< A connection with the server has been established.  Streaming has *not* started yet.
        r5_status_disconnected,         //!< The connection with the server has been lost.
        r5_status_connection_error,     //!< There was an error with the connection.
        r5_status_connection_timeout,   //!< The connection has failed due to timeout.
        r5_status_connection_close,     //!< The connection is fully closed.  Wait for this before releasing assets.
        r5_status_start_streaming,      //!< Streaming content has begun as a publisher or subscriber
        r5_status_stop_streaming,       //!< Streaming content has stopped.
        r5_status_netstatus,            //!< A netstatus event has been received from the server.
        r5_status_audio_mute,           //!< Publisher has muted their audio stream
        r5_status_audio_unmute,         //!< Publisher has unmuted their audio stream
        r5_status_video_mute,           //!< Publisher has muted their video stream
        r5_status_video_unmute,         //!< Publisher has unmuted their video stream
        r5_status_license_error,        //!< An error in validating the SDK license.
        r5_status_license_valid,        //!< The license key provided for the SDK is deemed valid.
        r5_status_buffer_flush_start,   //!< Publisher has started flushing queued packets post-broadcast.
        r5_status_buffer_flush_empty,   //!< Publisher has completed flushing queued packets post-broadcast.
        r5_status_video_render_start,   //!< Subscriber has rendered first video frame.
        r5_status_abr_level_change,     //!< ABR Publisher has changed broadcast level.
        r5_status_srtp_key_gen_error,   //!< There was a problem generating a key on this device.
        r5_status_srtp_key_handle_error, //!< There was a problem in the key exchange with the server.
        r5_status_hardware_decode_error //!< There was a problem using hardware acceleration to start decode of incoming stream.
    };

    /**
      \ingroup Global
     * Streaming mode for an R5Stream
     */
    typedef enum r5_stream_mode{
        r5_stream_mode_stop,
        r5_stream_mode_subscribe,
        r5_stream_mode_publish
    }r5_stream_mode_t;

    /**
      \ingroup Global
     * Buffering state of an R5Stream
     */
    enum r5_buffer_state{
        r5_buffer_state_buffered,
        r5_buffer_state_needs_rebuffer,
        r5_buffer_state_flush_buffer,
        r5_buffer_state_rebuffering
    };

    /**
      \ingroup Global
     * Scale modes for GL rendering of incoming streams
     */
    typedef enum r5_scale_mode{
        r5_scale_to_fill,   //scale to fill and maintain aspect ratio (cropping will occur)
        r5_scale_to_fit,    //scale to fit inside view (letterboxing will occur)
        r5_scale_fill       //scale to fill view (will not respect aspect ratio of video)
    }r5_scale_mode;

    /**
      \ingroup Global
     * Type of r5_media for encoding
     */
    typedef enum r5_media_type{
        r5_media_type_video,            //!< Standard video using R5Camera
        r5_media_type_audio,            //!< Standard audio using R5Microphone
        r5_media_type_video_custom,     //!< Custom video source
        r5_media_type_audio_custom      //!< Custom audio source
    } r5_media_type;

    /**
     \ingroup Global
     * Enum for stream format of incoming decoded stream data
     */
    typedef enum r5_stream_format {
        r5_stream_format_unknown,
        r5_stream_format_rgb,           //!< Non-hardware accelerated RGB. Uses SW Scalar for decode.
        r5_stream_format_yuv_planar,    //!< Non-hardware accelerated YUV. Parses frames into YUV 3 planes.
        r5_stream_format_yuv_biplanar,  //!< Non-hardware accelerated YUV. Parses frame to YUV bi-planar format.
    } r5_stream_format;

    /**
      \ingroup Global
     * Enum to match with protocol values in config and context
     */
    enum r5_protocol {
        r5_rtsp = 1,        //Basic flow
        r5_srtp = 2,        //rtsp with encrypted payloads and hash authentication
        r5_null_srtp = 3    //srtp without encryption
    };


    /**
     *  Client context
     */
    typedef struct client_ctx client_ctx;


    /**
      \ingroup Global
     *  Format r5_status events into a readable string
     *
     *  @param status r5_status to stringify
     *
     *  @return A string representation of the status code
     */
    const char * r5_string_for_status(int status);


    /**
      \ingroup Global
     *  Set logging level for the R5 Pro SDK
     *
     *  @param level r5_log_level of the level of logging desired
     */
    void r5_set_log_level(int level);

    /**
     *  Internal License validation
     *
     *  @return if build is valid or not
     */
    int requires_sdk_license(void);

    /**
      \ingroup Global
     *  @return The current logging level for the R5 Pro library
     */
    int r5_get_log_level(void);

    /**
     * Current stream time in ms
     */
    double now_ms(void);


    /**
     *  Stats for an R5Stream, returned by getDebugStats
     */
    typedef struct r5_stats{

        float                   buffered_time;              //!< Length of content that has been received on socket
        int                     subscribe_queue_size;       //!< Number of audio/video frames waiting for decode
        int                     nb_audio_frames;            //!< Number of queued audio frames to be played
        int                     nb_video_frames;            //!< Number of queued video frames to be played
        long                    pkts_received;              //!< Num Received packets
        long                    pkts_sent;                  //!< Num Sent packets
        long                    pkts_video_dropped;         //!< Incoming video packets dropped
        long                    pkts_audio_dropped;         //!< Incoming audio packets dropped
        long                    publish_pkts_dropped;       //!< Total audio/video packets dropped due to latency

        long                    total_bytes_received;       //!< Total bytes received by stream
        long                    total_bytes_sent;           //!< total bytes sent by stream
        float                   subscribe_bitrate;          //!< Subscribing bitrate  (not smoothed)
        float                   publish_bitrate;            //!< Publishing bitrate (not smoothed)
        long                    socket_queue_size;          //!< Num Packets queued to be sent out
        float                   bitrate_sent_smoothed;      //!< Smoothed outgoing bitrate
        float                   bitrate_received_smoothed;  //!< Smoothed incoming bitrate
        float                   subscribe_latency;          //!< How far behind subscriber clock the stream is arriving
        float                   video_decode_smoothed;      //!< How long it takes to decode video packet

    }r5_stats;

    /**
     *  Access Stats object for current stream
     *
     *  @param client Client to retrieve stats for
     *
     *  @return stats object with current state
     */
    r5_stats *r5_client_stats(client_ctx* client);


#ifdef __cplusplus
}
#endif

#endif
