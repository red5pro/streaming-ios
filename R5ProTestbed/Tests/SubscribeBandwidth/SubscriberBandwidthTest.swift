//
//  SubscriberBandwidthTest.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/17/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscriberBandwidthTest)
class SubscriberBandwidthTest: BaseTest {
    
    var overlay : UIView?

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
        
        
        
        overlay = UIView(frame: self.view.frame)
        overlay?.backgroundColor = UIColor.black
        self.view.addSubview(overlay!)
        
        let bgLayer = overlay!.layer;
        bgLayer.backgroundColor = UIColor.black.cgColor
        bgLayer.opacity = 0.0
        
        
    }
    
    override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        
        super.onR5StreamStatus( stream, withStatus: statusCode, withMessage: msg)
        
        if(statusCode == Int32(r5_status_netstatus.rawValue)){
            if(msg == "NetStream.Play.SufficientBW"){
                

                overlay!.layer.opacity = 0.0
            }else if(msg == "NetStream.Play.InSufficientBW"){
                
                overlay!.layer.opacity = 0.5
            }
        }
        
    }


}
