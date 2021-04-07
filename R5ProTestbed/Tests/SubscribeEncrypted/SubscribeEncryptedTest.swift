//
//  SubscribeEncryptedTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 6/26/18.
//  Copyright © 2018 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeEncryptedTest)
class SubscribeEncryptedTest: BaseTest {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        setupDefaultR5VideoViewController()
        
        let config = getConfig()
        config.protocol = Int32(r5_srtp.rawValue)
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
        self.subscribeStream?.client = self;
        
        currentView?.attach(subscribeStream)
        
        
        self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String, withHardwareAcceleration:Testbed.getParameter(param: "hwaccel_on") as! Bool)
        
    }
        
}
