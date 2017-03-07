//
//  SubscribeAspectRatioTest.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/18/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeAspectRatioTest)
class SubscribeAspectRatioTest: BaseTest {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        setupDefaultR5VideoViewController()
        
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
        
        currentView?.attach(subscribeStream)
        
        self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String)
        
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SubscribeAspectRatioTest.handleSingleTap(_:)))
        
        self.view.addGestureRecognizer(tap)
        
    }
    
    func handleSingleTap(_ recognizer : UITapGestureRecognizer) {
        
        var nextMode = (currentView?.scaleMode.rawValue)! + 1;
        if(nextMode == 3){
            nextMode = 0;
        }
        
        currentView?.scaleMode = r5_scale_mode(nextMode);
        
    }

}
