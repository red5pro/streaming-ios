//
//  PublishOrientationTest.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/18/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(PublishAspectTest)
class PublishAspectTest: BaseTest {

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in
            
        };
        
        
        setupDefaultR5VideoViewController()
        
        
        
        // Set up the configuration
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        
        setupPublisher(connection: connection!)
        // show preview and debug info
        
        self.currentView!.attach(publishStream!)
        
        self.currentView?.scaleMode = r5_scale_fill
        
        
        self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: R5RecordTypeLive)
        
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(recognizer:)))
        
        self.view.addGestureRecognizer(tap)
        
    }
    
    @objc func handleSingleTap(recognizer : UITapGestureRecognizer) {
        
        
        var nextMode = (currentView?.scaleMode.rawValue)! + 1;
        if(nextMode == 3){
            nextMode = 0;
        }
        
        currentView?.scaleMode = r5_scale_mode(nextMode);

    }
    
    override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        super.onR5StreamStatus(stream, withStatus: statusCode, withMessage: msg)
        if (Int(statusCode) == Int(r5_status_buffer_flush_start.rawValue)) {
            NotificationCenter.default.post(Notification(name: Notification.Name("BufferFlushStart")))
        }
        else if (Int(statusCode) == Int(r5_status_buffer_flush_empty.rawValue)) {
            NotificationCenter.default.post(Notification(name: Notification.Name("BufferFlushComplete")))
        }
    }

}
