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
        
    }
    
    override func onR5StreamStatus(stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        
        if(Int(statusCode) == Int(r5_status_start_streaming.rawValue)){
            
            let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
            
            self.view.addGestureRecognizer(tap)
        }
    }
    
    func handleSingleTap(recognizer : UITapGestureRecognizer) {
        
        var sendString : String = "";
        let touchLoc = recognizer.locationOfTouch(0, inView: self.view)
        let size = self.view.bounds.size
        
        sendString += "message=The publisher wants your attention;"
        sendString += "touchX=" + (touchLoc.x/size.width).description + ";"
        sendString += "touchY=" + (touchLoc.y/size.height).description
        
        publishStream?.send("whateverFunctionName", withParam: sendString)
    }
    
    
}
