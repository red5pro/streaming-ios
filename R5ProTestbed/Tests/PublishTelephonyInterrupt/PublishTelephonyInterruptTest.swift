//
//  PublishTelephonyInterruptTest.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 21/02/2019.
//  Copyright © 2019 Infrared5. All rights reserved.
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: .UIApplicationWillResignActive, object: nil)
        // Normal return from background.
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        // Return from interrupt.
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
        
    }
    
    @objc func willResignActive(_ notification: Notification) {
        publishStream?.pauseVideo = true
        
        self.tap = UITapGestureRecognizer(target: self, action: #selector(PublishSendTest.handleSingleTap(recognizer:)))
        self.view.addGestureRecognizer(self.tap!)
    }
    
    @objc func willEnterForeground(_ notification: Notification) {
        publishStream?.pauseVideo = false
        
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


