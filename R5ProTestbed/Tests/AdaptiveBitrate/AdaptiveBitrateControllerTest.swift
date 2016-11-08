//
//  AdaptiveBitrateControllerTest.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/16/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(AdaptiveBitrateControllerTest)
class AdaptiveBitrateControllerTest: BaseTest {

    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)

        setupDefaultR5VideoViewController()
        
        // Set up the configuration
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        
        setupPublisher(connection)
        // show preview and debug info
        
        self.currentView!.attachStream(publishStream!)
        
        //The Adaptive bitrate controller!
        let controller = R5AdaptiveBitrateController()
        controller.attachToStream(self.publishStream!)
        controller.requiresVideo = Testbed.getParameter("video_on") as! Bool
        
        
        self.publishStream!.publish(Testbed.getParameter("stream1") as! String, type: R5RecordTypeLive)
        
        
        
    }

}
