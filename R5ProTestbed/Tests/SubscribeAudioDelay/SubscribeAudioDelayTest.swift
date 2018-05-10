//
//  SubscribeAudioManipTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 4/30/18.
//  Copyright © 2018 Infrared5. All rights reserved.
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

