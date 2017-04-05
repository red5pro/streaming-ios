//
//  SubscribeAuthTest.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 4/5/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeAuthTest)
class SubscribeAuthTest: BaseTest {
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
    
        setupDefaultR5VideoViewController()
    
        // Set up the configuration
        let config = getConfig()
        let username = Testbed.localParameters!["username"] as! String
        let password = Testbed.localParameters!["password"] as! String
        config.parameters = "username=" + username + ";password=" + password + ";"
        
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
    
        currentView?.attach(subscribeStream)
    
        self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String)
        
    }

}
