//
//  SubscribeRemoteCallTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 4/27/16.
//  Copyright © 2015 Infrared5, Inc. All rights reserved.
// 
//  The accompanying code comprising examples for use solely in conjunction with Red5 Pro (the "Example Code") 
//  is  licensed  to  you  by  Infrared5  Inc.  in  consideration  of  your  agreement  to  the  following  
//  license terms  and  conditions.  Access,  use,  modification,  or  redistribution  of  the  accompanying  
//  code  constitutes your acceptance of the following license terms and conditions.
//  
//  Permission is hereby granted, free of charge, to you to use the Example Code and associated documentation 
//  files (collectively, the "Software") without restriction, including without limitation the rights to use, 
//  copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit 
//  persons to whom the Software is furnished to do so, subject to the following conditions:
//  
//  The Software shall be used solely in conjunction with Red5 Pro. Red5 Pro is licensed under a separate end 
//  user  license  agreement  (the  "EULA"),  which  must  be  executed  with  Infrared5,  Inc.   
//  An  example  of  the EULA can be found on our website at: https://account.red5pro.com/assets/LICENSE.txt.
// 
//  The above copyright notice and this license shall be included in all copies or portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,  INCLUDING  BUT  
//  NOT  LIMITED  TO  THE  WARRANTIES  OF  MERCHANTABILITY, FITNESS  FOR  A  PARTICULAR  PURPOSE  AND  
//  NONINFRINGEMENT.   IN  NO  EVENT  SHALL INFRARED5, INC. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
//  WHETHER IN  AN  ACTION  OF  CONTRACT,  TORT  OR  OTHERWISE,  ARISING  FROM,  OUT  OF  OR  IN CONNECTION 
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import UIKit
import R5Streaming

@objc(SubscribeRemoteCallTest)
class SubscribeRemoteCallTest: BaseTest {
    var label : UILabel? = nil

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        setupDefaultR5VideoViewController()
        
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
        self.subscribeStream?.client = self;
        
        currentView?.attach(subscribeStream)
        
        
        self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String, withHardwareAcceleration:Testbed.getParameter(param: "hwaccel_on") as! Bool)
        
    }
    
    @objc func whateverFunctionName(message: String){
        
        NSLog("Got this message: " + message)
        
        let splitMessage = message.characters.split(separator: ";").map(String.init)
        
        var message : String = ""
        var point : CGPoint = CGPoint()
        
        for item in splitMessage {
            
            let itemSplit = item.characters.split(separator: "=").map(String.init)
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
        
        DispatchQueue.main.async(execute: {
            
            if( self.label == nil){
                self.label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 24))
                self.label!.textAlignment = NSTextAlignment.left
                self.label!.backgroundColor = UIColor.lightGray
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
