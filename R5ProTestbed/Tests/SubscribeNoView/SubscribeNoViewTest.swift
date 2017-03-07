//
//  SubscribeNoViewTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 5/6/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeNoViewTest)
class SubscribeNoViewTest: BaseTest {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
        
        self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String)
    }
    
}
