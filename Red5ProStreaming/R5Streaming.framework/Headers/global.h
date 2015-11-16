//
//  global.h
//  Red5Pro
//
//  Created by Andy Zupko on 9/15/14.
//  Copyright (c) 2014 Andy Zupko. All rights reserved.
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
    
#define R5PRO_MAJOR_VERSION         0
#define R5PRO_MINOR_VERSION         8
#define R5PRO_REVISION              39
#define R5PRO_BUILD                 3
#define R5PRO_VERSION               "0.8.39.3"
#define R5PRO_VERSION_ISRELEASE     0
#define R5PRO_VERSION_CHECK(maj, min) ((maj==MYLIB_MAJOR_VERSION) && (min<=MYLIB_MINOR_VERSION))
    
    
#define SEC_TO_NANO 1e9
#define SEC_TO_MS 1e3


    typedef struct rpc_call rpc_call;
    typedef struct client_ctx client_ctx;
    typedef struct media_decoder media_decoder_t;
    



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
    
#define clean_errno() (errno == 0 ? "None" : strerror(errno))
    

    
#define check_mem(A) check((A), "Out of memory.")


//##define NDEBUG

int r5_valid_license();


enum r5_log_level{
    r5_log_level_debug,
    r5_log_level_info,
    r5_log_level_warn,
    r5_log_level_error
};

enum r5_status{
    r5_status_connected,
    r5_status_disconnected,
    r5_status_connection_error,
    r5_status_connection_timeout,
    r5_status_connection_close,
    r5_status_start_streaming,
    r5_status_stop_streaming,
    r5_status_netstatus
};
    

enum r5_stream_mode{
    r5_stream_mode_stop,
    r5_stream_mode_subscribe,
    r5_stream_mode_publish
};

typedef enum r5_stream_mode r5_stream_mode_t;
 
    
const char * r5_string_for_status(int status);

void r5_set_log_level(int level);
int r5_get_log_level();
    double now_ms(void);


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
        
        long                    log_time;
        long                    total_bytes_received;       //!< Total bytes received by stream
        long                    total_bytes_sent;           //!< total bytes sent by stream
        float                   subscribe_bitrate;          //!< Subscribing bitrate  (not smoothed)
        float                   publish_bitrate;            //!< Publishing bitrate (not smoothed)
        long                    socket_queue_size;          //!< Num Packets queued to be sent out
        float                   bitrate_sent_smoothed;      //!< Smoothed outgoing bitrate
        float                   bitrate_received_smoothed;  //!< Smoothed incoming bitrate
        float                   subscribe_latency;          //!< How far behind subscriber clock the stream is arriving
        
    }r5_stats;
    
    
    
    enum r5_buffer_state{
        r5_buffer_state_buffered,
        r5_buffer_state_needs_rebuffer,
        r5_buffer_state_rebuffering
    };
    
#ifdef __cplusplus
}
#endif

#endif
