//
//  session_description.h
//  red5streaming
//
//  Created by Andy Zupko on 10/27/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#ifndef __red5streaming__session_description__
#define __red5streaming__session_description__
#ifdef __cplusplus
extern "C" {
#endif
    
#define MAX_METADATA_COUNT 32

#include "parse_util.h"

    typedef enum {
        SDP_MEDIA_UNKNOWN,
        SDP_MEDIA_AUDIO,
        SDP_MEDIA_VIDEO
    } sdp_media_type;
    

    
    
    typedef struct media_description{
        
        sdp_media_type type;
        const char *control;
        const char *encoding;
        int format;
        int clock;
        int channels;
        uint16_t port;
        uint16_t portCount;
        keyvalue formats[10];
        int format_count;
        
    }media_description;
    
    typedef struct session_description{
        
        const char *control;
        media_description media[4];
        uint16_t media_count;
        keyvalue metadata[MAX_METADATA_COUNT];
        uint8_t meta_count;
        
    }session_description;
    
       
    int sdp_parse(session_description* session,
                  const char* data, int length);
    
    int has_audio(session_description* session);
    int has_video(session_description* session);
    
    const char* get_media_format_value(media_description* m, const char*key);
    void set_media_format_value(media_description* m, const char*key, const char*value);
    
    const char* get_metadata_value(session_description* s, const char*key);
    int set_metadata_value(session_description* s, const char*key, const char*value);
    
    media_description * get_media_description_of_type(session_description *session, sdp_media_type type);
    
    
#ifdef __cplusplus
}
#endif
        
#endif /* defined(__red5streaming__session_description__) */
