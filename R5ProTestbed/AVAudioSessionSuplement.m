//
//  AVAudioSessionSuplement.m
//  R5ProTestbed
//
//  Created by David Heimann on 4/15/19.
//  Copyright © 2019 Infrared5. All rights reserved.
//

#import "AVAudioSessionSuplement.h"

@implementation AVAudioSessionSuplement

+(BOOL)setCategory:(AVAudioSession*)session
          category:(AVAudioSessionCategory)category
           options:(AVAudioSessionCategoryOptions)options
             error:(NSError * _Nullable *)outError{
    return [session setCategory:category withOptions:options error:outError];
}

@end
