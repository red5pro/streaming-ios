//
//  SubscribeRemoteCallTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 4/27/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeRemoteCallTest)
class SubscribeRemoteCallTest: BaseTest {
    var label : UILabel? = nil

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
    
    func whateverFunctionName(message: String){
        
        NSLog("Got this message: " + message)
        
        let splitMessage = message.characters.split(";").map(String.init)
        
        var message : String = ""
        var point : CGPoint = CGPoint()
        
        for item in splitMessage {
            
            let itemSplit = item.characters.split("=").map(String.init)
            let size = self.view.frame.size
            switch itemSplit[0] {
            case "message":
                message = itemSplit[1]
                break
            case "touchX":
                point.x = CGFloat((itemSplit[1] as NSString).doubleValue) * size.width
                break
            case "touchY":
                point.y = CGFloat((itemSplit[1] as NSString).doubleValue) * size.height
                break
            default:
                break
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            
            if( self.label == nil){
                self.label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 24))
                self.label!.textAlignment = NSTextAlignment.Left
                self.label!.backgroundColor = UIColor.lightGrayColor()
                self.view.addSubview(self.label!)
            }
            
            self.label!.text = message
            
            var frame = self.label!.frame
            frame.origin = point
            self.label!.frame = frame
            self.label!.sizeToFit()
        })
        
    }
}
