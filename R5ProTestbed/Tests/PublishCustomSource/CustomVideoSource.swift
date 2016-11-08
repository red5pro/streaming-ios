//
//  CustomVideoSource.swift
//  R5ProTestbed
//
//  Created by David Heimann on 5/9/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(CustomVideoSource)
class CustomVideoSource : R5VideoSource {
    
    var frameDuration : CMTime;
    var PTS : CMTime;
    var timer : NSTimer?;
    
    override init() {
        
        let fpsVal: Int32 = 15;
        
        //setup simple timestamp calculation
        self.frameDuration = CMTimeMakeWithSeconds(0.1, fpsVal);
        self.PTS = kCMTimeZero;
        self.timer = nil;
        
        super.init();
        
        //initialize the properties used by the stream!
        self.bitrate = 256;
        self.width = 320;
        self.height = 240;
        self.orientation = 0;
        self.fps = fpsVal;
    }
    
    override func startVideoCapture() {
        
        //start a timer to run at desired framerate.
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0 / Double(self.fps),
                                                            target: self,
                                                            selector: #selector(capturePixels),
                                                            userInfo: nil,
                                                            repeats: true);
    }
    
    override func stopVideoCapture() {
        
        //stop the capture!
        self.timer!.invalidate();
    }
    
    func capturePixels( time:NSTimer ){
        
        //make sure encoding layer is ready for input!
        if(self.encoder != nil){
            
            let frameSize: CGSize = CGSizeMake(352, 288);
            
            //
            //  Below is a simple "plasma" style rendering using the PTS as the animation offset
            //  Using RGB color format - 3 bytes per pixel
            //
            
            let time: Float = Float( CMTimeGetSeconds(self.PTS) * 0.6 );
            let scale: Float = 0.035;
            let componentsPerPixel = 3;
            let rgbPixels: UnsafeMutablePointer<__uint8_t> = UnsafeMutablePointer<__uint8_t>.alloc(Int(frameSize.width * frameSize.height) * componentsPerPixel);
            
            //stride
            let bpr: Int = Int(frameSize.width) * componentsPerPixel;
            
            for y in 0..<Int(frameSize.height) {
                for x in 0..<Int(frameSize.width) {
                    
                    var cx: Float = Float(x) / Float(componentsPerPixel) * scale;
                    var cy = Float(y) * scale;
                    
                    var v: Float = sinf(cx+time);
                    v += sinf(cy+time);
                    v += sinf(cx+cy+time);
                    
                    cx += scale * sinf(time*0.33);
                    cy += scale * cosf(time*0.2);
                    
                    v += sinf(sqrtf(cx*cx + cy*cy + 1.0)+time);
                    
                    //Set the R, G, B channels to the desired color
                    rgbPixels[(y * bpr) + (componentsPerPixel*x)] = __uint8_t( max( Double(sinf( v * Float(M_PI) )) * Double(UINT8_MAX), 0) );
                    rgbPixels[(y * bpr) + (componentsPerPixel*x)+1] = __uint8_t( max( Double(cosf( v * Float(M_PI) )) * Double(UINT8_MAX), 0) );
                    rgbPixels[(y * bpr) + (componentsPerPixel*x)+2] = 0;
                }
            }
            
            // Create a pixel buffer
            var pixelBuffer: CVPixelBuffer?;
            
            //Create a pixel buffer to hold our bytes with RGB format
            var result: OSStatus = CVPixelBufferCreateWithBytes(kCFAllocatorDefault,
                                                                Int(frameSize.width),
                                                                Int(frameSize.height),
                                                                kCVPixelFormatType_24RGB,
                                                                rgbPixels,
                                                                Int(frameSize.width) * componentsPerPixel,
                                                                nil,
                                                                &pixelBuffer,
                                                                nil,
                                                                &pixelBuffer);
            
            if(result != kCVReturnSuccess){
                NSLog("Failed to get pixel buffer");
            }
            
            var videoInfo: CMVideoFormatDescriptionRef?;
            
            //Create a description for the pixel buffer
            result = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer!, &videoInfo);
            
            if(result != kCVReturnSuccess) {
                NSLog("Failed to create video info");
            }
            
            //Only PTS is needed for the encoder - leave everything else invalid if you want
            var timingInfo: CMSampleTimingInfo = kCMTimingInfoInvalid;
            timingInfo.duration = kCMTimeInvalid;
            timingInfo.decodeTimeStamp = kCMTimeInvalid;
            timingInfo.presentationTimeStamp = self.PTS;
            
            var buffer: CMSampleBufferRef?;
            
            //Create the sample buffer for the pixel buffer
            result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,
                                                        pixelBuffer!,
                                                        true, nil, nil,
                                                        videoInfo!,
                                                        &timingInfo,
                                                        &buffer);
            
            //push the sample buffer to the encoder with type r5_media_type_video_custom
            if(!self.pauseEncoding){
                self.encoder.encodeFrame( buffer, ofType: r5_media_type_video_custom );
            }
            
            //increment our timestamp
            self.PTS = CMTimeAdd(self.PTS, self.frameDuration);
            
            //free all our content
            free(rgbPixels);
        }
    }
}
