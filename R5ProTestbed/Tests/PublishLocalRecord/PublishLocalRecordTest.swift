//
//  PublishLocalRecordTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 7/31/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(PublishLocalRecordTest)
class PublishLocalRecordTest: PublishTest {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let vidRate = (Testbed.getParameter(param: "bitrate") as! Int)*2
        let props = [R5RecordVideoBitRateKey: vidRate,
                     R5RecordAudioBitRateKey: 32,
                     R5RecordAlbumName: "r5Pro"] as [String : Any]
        
        self.publishStream!.record(withName: "fileTest", withProps: props)
    }
    
}
