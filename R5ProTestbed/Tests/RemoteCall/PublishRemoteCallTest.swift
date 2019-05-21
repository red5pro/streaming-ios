//
//  PublishRemoteCallTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 4/26/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(PublishRemoteCallTest)
class PublishRemoteCallTest: BaseTest {
    
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
        
        
        self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: getPublishRecordType ())
        
    }
    
    override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        
        super.onR5StreamStatus(stream, withStatus: statusCode, withMessage: msg)
        
        if(Int(statusCode) == Int(r5_status_start_streaming.rawValue)) {
            let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(recognizer:)))
            self.view.addGestureRecognizer(tap)
        }
        else if (Int(statusCode) == Int(r5_status_buffer_flush_start.rawValue)) {
            NotificationCenter.default.post(Notification(name: Notification.Name("BufferFlushStart")))
        }
        else if (Int(statusCode) == Int(r5_status_buffer_flush_empty.rawValue)) {
            NotificationCenter.default.post(Notification(name: Notification.Name("BufferFlushComplete")))
        }
        
    }
    
    @objc func handleSingleTap(recognizer : UITapGestureRecognizer) {
        
        var sendString : String = "";
        let touchLoc = recognizer.location(ofTouch: 0, in: self.view)
        let size = self.view.bounds.size
        
        sendString += "message=The publisher wants your attention;"
        sendString += "touchX=" + (touchLoc.x/size.width).description + ";"
        sendString += "touchY=" + (touchLoc.y/size.height).description
        
        publishStream?.send("whateverFunctionName", withParam: sendString)
    }
    
}
