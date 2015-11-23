//
//  ColorsVideoSource.m
//  Red5Pro
//
//  Created by Andy Zupko on 11/17/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

#import "ColorsVideoSource.h"

@implementation ColorsVideoSource

-(instancetype)init{
    
    if((self = [super init]) != nil){
        
        //initialize the properties used by the stream!
        self.bitrate = 256;
        self.width = 320;
        self.height = 240;
        self.orientation = 0;
        self.fps = 15;
        
        //setup simple timestamp calculation
        self.frameDuration = CMTimeMakeWithSeconds(0.1f, self.fps);
        self.PTS = kCMTimeZero;
        
    }
    
    return self;
}

-(void)startVideoCapture{
    
    //start a timer to run at desired framerate.
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f/self.fps
                                     target:self
                                   selector:@selector(capturePixels:)
                                   userInfo:nil
                                    repeats:YES];
    

}

-(void)stopVideoCapture{
    
    //stop the capture!
    [self.timer invalidate];
}



-(void)capturePixels:(NSTimer *)timer{
    
    //make sure encoding layer is ready for input!
    if(self.encoder != nil){
        
        CGSize frameSize = CGSizeMake(352, 288);
        
        //
        //  Below is a simple "plasma" style rendering using the PTS as the animation offset
        //  Using RGB color format - 3 bytes per pixel
        //
        
        float time = CMTimeGetSeconds(self.PTS) * 0.6f;
        
        float scale = 0.035f;
        
        int componentsPerPixel = 3;
        
        uint8_t *rgbpixels = (uint8_t*)malloc(frameSize.width*frameSize.height*componentsPerPixel);
        
        //stride
        int bpr = frameSize.width*componentsPerPixel;
        
        for(int y = 0;y<frameSize.height;y++){
            for(int x=0;x<bpr;x+=componentsPerPixel){
                
                float cx = x / componentsPerPixel * scale;
                float cy = y * scale;
                
                float v = sinf(cx+time);
                v += sinf(cy+time);
                v += sinf(cx+cy+time);
                
                cx += scale * sinf(time*0.33f);
                cy += scale * cosf(time*0.2f);
                
                v += sinf(sqrtf(cx*cx +cy*cy+1.0)+time);

                //Set the R, G, B channels to the desired color
                rgbpixels[(y * bpr)+x]   = sinf(v*M_PI) * UINT8_MAX;
                rgbpixels[(y * bpr)+x+1] = cosf(v*M_PI)* UINT8_MAX ;
                rgbpixels[(y * bpr)+x+2] = 0;
            }
        }
        
        
        // Create a pixel buffer
        CVPixelBufferRef pixelBuffer = NULL;
        
        //Create a pixel buffer to hold our bytes with RGB format
        OSStatus result =  CVPixelBufferCreateWithBytes(kCFAllocatorDefault, frameSize.width, frameSize.height,   kCVPixelFormatType_24RGB , rgbpixels, frameSize.width * (componentsPerPixel), NULL, (void*)pixelBuffer, NULL, &pixelBuffer);
        

        if(result != kCVReturnSuccess){
            
            LOGE("Failed to get pixel buffer");

        }
        
        CMVideoFormatDescriptionRef videoInfo = NULL;
        
        //Create a description for the pixel buffer
        result = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &videoInfo);
        
        if(result != kCVReturnSuccess)
            NSLog(@"Failed to create video info");
        
        //Only PTS is needed for the encoder - leave everything else invalid if you want
        CMSampleTimingInfo timingInfo = kCMTimingInfoInvalid;
        timingInfo.duration = kCMTimeInvalid;
        timingInfo.decodeTimeStamp = kCMTimeInvalid;
        timingInfo.presentationTimeStamp = self.PTS;
        
        
        CMSampleBufferRef buffer = NULL;
        
        //Create the sample buffer for the pixel buffer!
        result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,
                                                    pixelBuffer,
                                                    true, NULL, NULL,
                                                    videoInfo,
                                                    &timingInfo,
                                                    &buffer);
        
        //push the sample buffer to the encoder with type r5_media_type_video_custom
        if(!self.pauseEncoding)
            [self.encoder encodeFrame:buffer ofType:r5_media_type_video_custom];
        
        
        //increment our timestamp!
        self.PTS = CMTimeAdd(self.PTS, self.frameDuration);
        
        //free all our content!
        CFRelease(buffer);
        CFRelease(pixelBuffer);
        free(rgbpixels);
    

    }
       
}



@end
