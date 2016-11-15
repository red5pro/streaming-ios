//
//  SubscribeAspectRatioTest.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/18/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeSetSizeTest)
class SubscribeSetSizeTest: BaseTest {
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setupR5VideoViewController()
        
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
        
        currentView?.attachStream(subscribeStream)
        
        self.subscribeStream!.play(Testbed.getParameter("stream1") as! String)
        
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        
        self.view.addGestureRecognizer(tap)
        
    }
    
    func setupR5VideoViewController() -> R5VideoViewController{
        
        let r5View : R5VideoViewController = getNewR5VideoViewController(self.view.frame);
        self.addChildViewController(r5View);
        
               view.addSubview(r5View.view)
        
        r5View.showPreview(true)
        
        r5View.showDebugInfo(Testbed.getParameter("debug_view") as! Bool)
        
        currentView = r5View;

        r5View.setFrame(CGRect(x: 100, y: 100, width: 200, height: 200));

        return currentView!
    }
    
    func handleSingleTap(recognizer : UITapGestureRecognizer) {
        
            currentView!.setFrame(CGRect(x: 100, y: 100, width: 200, height: 200));
        
    }
    
    override func viewDidLayoutSubviews() {
        

        if(currentView != nil){
            
           // currentView?.setFrame(view.frame);
        }
        
    }

}
