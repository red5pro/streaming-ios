//
//  PublishHQAudioTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 7/14/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(PublishHQAudioTest)
class PublishHQAudioTest: BaseTest {
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in
            
        };
        
        
        setupDefaultR5VideoViewController()
        
        // Set up the configuration
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        
        setupPublisher(connection!)
        // show preview and debug info
        self.currentView!.attach(publishStream!)
        
        //Set the desired properties of the microphone
        self.publishStream?.getMicrophone().sampleRate = 44100;//hz (samples/second)
        self.publishStream?.getMicrophone().bitrate = 128;//kb/s
        
        self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: R5RecordTypeLive)
        
        
        
    }
}
