//
//  SubscribeAudioManipTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 4/30/18.
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

@objc(SubscribeAudioDelayTest)
class SubscribeAudioDelayTest: SubscribeTest {
    
    var sampleBuffer: [SampleHolder]? = []
    var sampleDelay = 1000.0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        subscribeStream!.setPlaybackAudioHandler({ (sampleData, samples, timeMillis) in
            
            if(sampleData == nil || self.sampleBuffer == nil){
                return // we can't manipulate data if we haven't been pointed to any
            }
            
            let newSample = SampleHolder.init()
            newSample.sampleData = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(samples))
            newSample.samples = samples
            newSample.timeStamp = timeMillis

            newSample.sampleData!.initialize(from: sampleData!, count: Int(samples))

            self.sampleBuffer!.append(newSample)
            
            if(self.sampleBuffer![0].timeStamp <= timeMillis - self.sampleDelay){
                // each call will likely have the a different number of samples
                // so we run checks to prevent overflow and discarded information
                var samplesPassed: Int32 = 0
                while(samplesPassed < samples){
                    let pastSample = self.sampleBuffer![0]
                    let passing = min(pastSample.samples - pastSample.offset, samples - samplesPassed)
                    sampleData!.advanced(by: Int(samplesPassed)).initialize(
                        from: pastSample.sampleData!.advanced(by: Int(pastSample.offset)),
                        count: Int(passing)
                    )
                    samplesPassed += passing

                    if(pastSample.offset + passing < pastSample.samples){
                        pastSample.offset += passing
                    }
                    else{
                        self.sampleBuffer!.removeFirst()
                        pastSample.sampleData!.deallocate(capacity: Int(pastSample.samples))
                    }
                }
            }
            else{
                sampleData!.initialize(to: 0, count: Int(samples))
            }
        })
    }
    
    override func closeTest() {
        super.closeTest()
        
        //We're handling raw memory, release everything
        for s in sampleBuffer! {
            s.sampleData?.deallocate(capacity: Int(s.samples))
        }
        //nullify the array to end processing, just in case
        sampleBuffer = nil
    }
}

@objc(SampleHolder)
class SampleHolder: NSObject {
    var sampleData: UnsafeMutablePointer<UInt8>? = nil
    var samples: Int32 = 0
    var offset: Int32 = 0
    var timeStamp: Double = 0.0
}

