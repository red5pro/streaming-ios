//
//  PublishOrientationTest.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/18/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(PublishOrientationTest)
class PublishOrientationTest: BaseTest {

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
        
        
        self.publishStream!.publish(Testbed.getParameter("stream1") as! String, type: R5RecordTypeLive)
        
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        
        self.view.addGestureRecognizer(tap)
        
    }
    
    func handleSingleTap(recognizer : UITapGestureRecognizer) {
        
        let cam = self.publishStream?.getVideoSource() as! R5Camera
        
        cam.orientation = cam.orientation + 90
        
        self.publishStream?.updateStreamMeta()
        
    }
    


}
