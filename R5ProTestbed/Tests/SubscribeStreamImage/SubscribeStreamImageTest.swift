//
//  PublishStreamImageTest.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/17/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeStreamImageTest)
class SubscribeStreamImageTest: BaseTest {
    
    var uiv : UIImageView? = nil
    
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
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        
        self.view.addGestureRecognizer(tap)
        
        
        uiv = UIImageView(frame: CGRect(x: 0, y: self.view.frame.height-200, width: 300, height: 200))
        uiv!.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(uiv!);
        
    }
    
    func handleSingleTap(recognizer : UITapGestureRecognizer) {
        
        
        uiv!.image = self.subscribeStream?.getStreamImage();
        
    }
    
    
}
