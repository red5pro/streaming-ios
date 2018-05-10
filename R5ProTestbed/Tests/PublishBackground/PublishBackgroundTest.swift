//
//  PublishBackgroundTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 5/1/18.
//  Copyright © 2018 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(PublishBackgroundTest)
class PublishBackgroundTest: PublishTest {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        shouldClose = false;
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc func willResignActive(_ notification: Notification) {
        publishStream?.pauseVideo = true
    }
    
    @objc func willEnterForeground(_ notification: Notification) {
        publishStream?.pauseVideo = false
    }
    
    override func closeTest() {
        NotificationCenter.default.removeObserver(self)
        
        super.closeTest()
    }
    
}

