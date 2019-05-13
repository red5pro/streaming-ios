//
//  SubscribeMetalViewTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 1/10/19.
//  Copyright © 2019 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeMetalViewTest)
class SubscribeMetalViewTest: BaseTest {
    
    var metalView: R5MetalVideoViewController? = nil;
    
    var current_rotation = 0;
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        setupR5MetalVideoViewController()
        
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        
        metalView?.attach(subscribeStream)
        
        self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String)
        
    }

    func setupR5MetalVideoViewController() {
        
        let view : UIView = UIView(frame: self.view.frame)
        
        metalView = R5MetalVideoViewController();
        metalView!.view = view;
        
        self.addChild(metalView!)
        self.view.addSubview(metalView!.view)
        
        metalView?.setFrame(self.view.bounds)
        
        metalView?.showPreview(true)
        
        metalView?.showDebugInfo(Testbed.getParameter(param: "debug_view") as! Bool)
        
    }
}
