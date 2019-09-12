//
//  PublishTelephonyInterruptTest.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 21/02/2019.
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

@objc(PublishTelephonyInterruptTest)
class PublishTelephonyInterruptTest: PublishTest {
    
    var tap : UITapGestureRecognizer? = nil
    var hasReturnedToForeground = false
    
    override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        
        NSLog("Status: %s ", r5_string_for_status(statusCode))
        let s =  String(format: "Status: %s (%@)",  r5_string_for_status(statusCode), msg)
        ALToastView.toast(in: self.view, withText:s)
        
        if (Int(statusCode) == Int(r5_status_disconnected.rawValue)) {
            self.cleanup()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        shouldClose = false;
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        // Normal return from background.
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        // Return from interrupt.
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
    }
    
    @objc func willResignActive(_ notification: Notification) {
        publishStream?.pauseVideo = true
        
        let streamName = Testbed.getParameter(param: "stream1") as? String
        publishStream?.send("publisherBackground", withParam: "streamName=\(streamName)")
        
        self.tap = UITapGestureRecognizer(target: self, action: #selector(PublishSendTest.handleSingleTap(recognizer:)))
        self.view.addGestureRecognizer(self.tap!)
    }
    
    @objc func willEnterForeground(_ notification: Notification) {
        publishStream?.pauseVideo = false
        
        let streamName = Testbed.getParameter(param: "stream1") as? String
        publishStream?.send("publisherForeground", withParam: "streamName=\(streamName)")
        
        hasReturnedToForeground = true
        if (tap != nil) {
            self.view.removeGestureRecognizer(self.tap!)
            tap = nil
        }
    }
    
    @objc func didBecomeActive(_ notification: Notification) {
        if (publishStream != nil && !hasReturnedToForeground) {
            let streamName = Testbed.getParameter(param: "stream1") as? String
            publishStream?.send("publisherInterrupt", withParam: "streamName=\(streamName)")
            publishStream?.stop()
        }
        hasReturnedToForeground = false
        
        if (tap != nil) {
            ALToastView.toast(in: self.view, withText:"Tap to Re-Publish!")
        }
    }
    
    func republish () {
        // Set up the configuration
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        
        setupPublisher(connection: connection!)
        self.currentView!.attach(publishStream!)
        self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: R5RecordTypeLive)
    }
    
    func handleSingleTap(recognizer : UITapGestureRecognizer) {
        if (self.tap != nil) {
            self.view.removeGestureRecognizer(self.tap!)
            tap = nil
        }
        republish()
    }
    
    override func closeTest() {
        NotificationCenter.default.removeObserver(self)
        super.closeTest()
    }
    
}


