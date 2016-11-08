//
//  parse_util.h
//  Streaming
//
//  Created by Zach Kamsler on 4/23/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#ifndef Streaming_parse_util_h
#define Streaming_parse_util_h
#ifdef __cplusplus
extern "C" {
#endif
    
    
#include <stdint.h>

#define CHECK_PREFIX(p, end, literal) ( \
( ((p) - (end)) >= (sizeof(literal)-1) ) && \
( memcmp(literal, p, sizeof(literal)-1) == 0 ) \
)

#define AFTER(p, literal) ((p) + sizeof(literal) - 1);
    
    typedef struct keyvalue{
        const char* key;
        const char* value;
    }keyvalue;

    typedef struct timehash{
        struct timehash *next;
        const char* key;
        double value;
    }timehash;

static inline int r5_is_digit(char c) {
    return c >= '0' && c <= '9';
}

int r5_parse_int(const char* start, long length);
uint32_t r5_parse_hex(const char* start, long length);

char* r5_parse_str(const char*start, long length);

    
int r5_parse_map(const char*data, long length, keyvalue *keys);
    
void tonet_short(uint8_t* p, unsigned short s);
void tonet_long(uint8_t* p, unsigned long l);
    
void timehash_set(timehash *hash, char *key, double value);
int timehash_get(timehash *hash, char *key, double* value);
int timehash_contains(timehash *hash, char* key);
    
void timehash_release(timehash *hash);
    
timehash* timehash_create();

    

    
#ifdef __cplusplus
}
#endif
        
#endif
