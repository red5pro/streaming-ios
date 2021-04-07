//
//  CustomVideoSource.swift
//  R5ProTestbed
//
//  Created by David Heimann on 5/9/16.
//  Copyright © 2015 Infrared5, Inc. All rights reserved.
// 
//  The accompanying code comprising examples for use solely in conjunction with Red5 Pro (the "Example Code") 
//  is  licensed  to  you  by  Infrared5  Inc.  in  consideration  of  your  agreement  to  the  following  
//  license terms  and  conditions.  Access,  use,  modification,  or  redistribution  of  the  accompanying  
//  code  constitutes your acceptance of the following license terms and conditions.
//  
//  Permission is hereby granted, free of charge, to you to use the Example Code and associated documentation 
//  files (collectively, the "Software") without restriction, including without limitation the rights to use, 
//  copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit 
//  persons to whom the Software is furnished to do so, subject to the following conditions:
//  
//  The Software shall be used solely in conjunction with Red5 Pro. Red5 Pro is licensed under a separate end 
//  user  license  agreement  (the  "EULA"),  which  must  be  executed  with  Infrared5,  Inc.   
//  An  example  of  the EULA can be found on our website at: https://account.red5pro.com/assets/LICENSE.txt.
// 
//  The above copyright notice and this license shall be included in all copies or portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,  INCLUDING  BUT  
//  NOT  LIMITED  TO  THE  WARRANTIES  OF  MERCHANTABILITY, FITNESS  FOR  A  PARTICULAR  PURPOSE  AND  
//  NONINFRINGEMENT.   IN  NO  EVENT  SHALL INFRARED5, INC. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
//  WHETHER IN  AN  ACTION  OF  CONTRACT,  TORT  OR  OTHERWISE,  ARISING  FROM,  OUT  OF  OR  IN CONNECTION 
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import UIKit
import R5Streaming

@objc(CustomVideoSource)
class CustomVideoSource : R5VideoSource {
    
    var frameDuration : CMTime;
    var PTS : CMTime;
    var timer : Timer?;
    
    override init() {
        
        let fpsVal: Int32 = 15;
        
        //setup simple timestamp calculation
        self.frameDuration = CMTimeMakeWithSeconds(1.0/Double(fpsVal), preferredTimescale: fpsVal);
        self.PTS = CMTime.zero;
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
        self.timer = Timer.scheduledTimer(timeInterval: 1.0 / Double(self.fps),
                                                            target: self,
                                                            selector: #selector(capturePixels),
                                                            userInfo: nil,
                                                            repeats: true);
    }
    
    override func stopVideoCapture() {
        
        //stop the capture!
        self.timer!.invalidate()
        
        //stop the encoder!
        super.stopVideoCapture()
    }
    
    @objc func capturePixels( time:Timer ){
        
        //make sure encoding layer is ready for input!
        if(self.encoder != nil){
            
            let frameSize: CGSize = CGSize(width: 352, height: 288);
            
            //
            //  Below is a simple "plasma" style rendering using the PTS as the animation offset
            //  Using RGB color format - 3 bytes per pixel
            //
            
            let time: Float = Float( CMTimeGetSeconds(self.PTS) * 0.6 );
            let scale: Float = 0.035;
            let componentsPerPixel = 3;
            let rgbPixels: UnsafeMutablePointer<__uint8_t> = UnsafeMutablePointer<__uint8_t>.allocate(capacity: Int(frameSize.width * frameSize.height) * componentsPerPixel);
            
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
                    rgbPixels[(y * bpr) + (componentsPerPixel*x)] = __uint8_t( max( Double(sinf( v * Float.pi )) * Double(UINT8_MAX), 0) );
                    rgbPixels[(y * bpr) + (componentsPerPixel*x)+1] = __uint8_t( max( Double(cosf( v * Float.pi )) * Double(UINT8_MAX), 0) );
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
                                                                nil,
                                                                nil,
                                                                &pixelBuffer);
            
            if(result != kCVReturnSuccess){
                NSLog("Failed to get pixel buffer");
            }
            
            var videoInfo: CMVideoFormatDescription?;
            
            //Create a description for the pixel buffer
            result = CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer!, formatDescriptionOut: &videoInfo);
            
            if(result != kCVReturnSuccess) {
                NSLog("Failed to create video info");
            }
            
            //Only PTS is needed for the encoder - leave everything else invalid if you want
            var timingInfo: CMSampleTimingInfo = CMSampleTimingInfo.invalid;
            timingInfo.duration = CMTime.invalid;
            timingInfo.decodeTimeStamp = CMTime.invalid;
//            timingInfo.presentationTimeStamp = self.PTS;
            
            let aTime:Double = R5AudioController.getCurrentPubTime();
            timingInfo.presentationTimeStamp = CMTimeMakeWithSeconds(aTime, preferredTimescale: 1000)
            
            var buffer: CMSampleBuffer?;
            
            //Create the sample buffer for the pixel buffer
            result = CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                        imageBuffer: pixelBuffer!,
                                                        dataReady: true, makeDataReadyCallback: nil, refcon: nil,
                                                        formatDescription: videoInfo!,
                                                        sampleTiming: &timingInfo,
                                                        sampleBufferOut: &buffer);
            
            //push the sample buffer to the encoder with type r5_media_type_video_custom
            
            self.encoder.encodeFrame( buffer, of: r5_media_type_video_custom );
   
            
            //increment our timestamp
            self.PTS = CMTimeAdd(self.PTS, self.frameDuration);
            
            //free all our content
            free(rgbPixels);
        }
    }
}
