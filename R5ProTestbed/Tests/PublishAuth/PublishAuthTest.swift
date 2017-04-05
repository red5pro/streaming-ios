//
//  PublishAuthTest.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 4/4/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(PublishAuthTest)
class PublishAuthTest: BaseTest {
    
    
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
        setupPublisher(connection: connection!)
        
        // show preview and debug info
        self.currentView!.attach(publishStream!)
        
        self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: R5RecordTypeRecord)
        
    }
}
