//
//  AVAudioSessionSuplement.h
//  R5ProTestbed
//
//  Created by David Heimann on 4/15/19.
//  Copyright © 2019 Infrared5. All rights reserved.
//

#ifndef AVAudioSessionSuplement_h
#define AVAudioSessionSuplement_h

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AVAudioSessionSuplement : NSObject

+(BOOL)setCategory:(AVAudioSession*)session
          category:(AVAudioSessionCategory)category
           options:(AVAudioSessionCategoryOptions)options
             error:(NSError * _Nullable *)outError;

@end

#endif /* AVAudioSessionSuplement_h */
