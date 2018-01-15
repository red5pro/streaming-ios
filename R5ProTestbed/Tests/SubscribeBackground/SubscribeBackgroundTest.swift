//
//  SubscribeBackgroundTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 1/3/18.
//  Copyright © 2018 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeBackgroundTest)
class SubscribeBackgroundTest: SubscribeTest {
    
    var endBtn: UIButton? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        shouldClose = false;
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc func willResignActive(_ notification: Notification) {
        currentView?.pauseRender()
    }
    
    @objc func willEnterForeground(_ notification: Notification) {
        currentView?.resumeRender()
    }
    
    override func closeTest() {
        NotificationCenter.default.removeObserver(self)
        
        super.closeTest()
    }
    
}
