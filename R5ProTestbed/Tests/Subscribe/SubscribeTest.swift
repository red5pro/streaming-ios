//
//  SubscribeTestViewController.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/16/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeTest)
class SubscribeTest: BaseTest {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        setupDefaultR5VideoViewController()
        
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
        self.subscribeStream?.client = self;
        
        currentView?.attachStream(subscribeStream)
        
        
        self.subscribeStream!.play(Testbed.getParameter("stream1") as! String)
        
        

    }
    
    
    func onMetaData(data : String){
        
    }
    
    

}
