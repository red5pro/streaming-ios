//
//  SubscribeTwoStreams.swift
//  R5ProTestbed
//
//  Created by David Heimann on 3/14/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeTwoStreams)
class SubscribeTwoStreams: BaseTest {
    var firstView : R5VideoViewController? = nil
    var secondView : R5VideoViewController? = nil
    var subscribeStream2 : R5Stream? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let screenSize = self.view.bounds.size
        
        firstView = getNewR5VideoViewController(CGRect( x: 0, y: 0, width: screenSize.width, height: screenSize.height / 2 ))
        self.addChildViewController(firstView!)
        view.addSubview((firstView?.view)!)
        firstView?.showDebugInfo(Testbed.getParameter("debug_view") as! Bool)
        
        firstView?.view.center = CGPoint( x: screenSize.width/2, y: screenSize.height/4 )
        
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
        self.subscribeStream?.client = self;
        
        firstView?.attachStream(subscribeStream)
        
        self.subscribeStream!.audioController = R5AudioController(mode: R5AudioControllerModeStandardIO)
        
        self.subscribeStream!.play(Testbed.getParameter("stream1") as! String)
        
        
        let connection2 = R5Connection(config: config)
        
        self.subscribeStream2 = R5Stream(connection: connection2 )
        self.subscribeStream2!.delegate = self
        self.subscribeStream2?.client = self;
        
        secondView = getNewR5VideoViewController(CGRect( x: 0, y: screenSize.height / 2, width: screenSize.width, height: screenSize.height / 2 ))
        self.addChildViewController(secondView!)
        view.addSubview((secondView?.view)!)
        secondView?.showDebugInfo(Testbed.getParameter("debug_view") as! Bool)
        
        secondView?.view.center = CGPoint( x: screenSize.width/2, y: 3 * (screenSize.height/4) )
        
        secondView?.attachStream(subscribeStream2)
        
        self.subscribeStream2?.audioController = R5AudioController(mode: R5AudioControllerModeEchoCancellation)
        
        self.subscribeStream2?.play(Testbed.getParameter("stream2") as! String)
    }
    
    func onMetaData(data : String){
        
    }
    
    override func closeTest() {
        super.closeTest()
        
        if( self.subscribeStream2 != nil ){
            self.subscribeStream2!.stop()
        }
    }
}
