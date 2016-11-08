//
//  RecordedTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 3/15/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(RecordedTest)
class RecordedTest: BaseTest {
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in
            
        };
        
        
        setupDefaultR5VideoViewController()
        
        // Set up the configuration
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        
        setupPublisher(connection)
        // show preview and debug info
        
        self.currentView!.attachStream(publishStream!)
        
        
        self.publishStream!.publish(Testbed.getParameter("stream1") as! String, type: R5RecordTypeRecord)
        
        
        
    }
}
