//
//  SubscribeTwoStreams.swift
//  R5ProTestbed
//
//  Created by David Heimann on 3/14/16.
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

@objc(SubscribeTwoStreams)
class SubscribeTwoStreams: BaseTest {
    var firstView : R5VideoViewController? = nil
    var secondView : R5VideoViewController? = nil
    var subscribeStream2 : R5Stream? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let screenSize = self.view.bounds.size
        
        firstView = getNewR5VideoViewController(rect: CGRect( x: 0, y: 0, width: screenSize.width, height: screenSize.height / 2 ))
        self.addChild(firstView!)
        view.addSubview((firstView?.view)!)
        firstView?.showDebugInfo(Testbed.getParameter(param: "debug_view") as! Bool)
        
        firstView?.view.center = CGPoint( x: screenSize.width/2, y: screenSize.height/4 )
        
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
        self.subscribeStream?.client = self;
        
        firstView?.attach(subscribeStream)
        
        self.subscribeStream!.audioController = R5AudioController()
        
        self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String, withHardwareAcceleration:Testbed.getParameter(param: "hwaccel_on") as! Bool)
        
        secondView = getNewR5VideoViewController(rect: CGRect( x: 0, y: screenSize.height / 2, width: screenSize.width, height: screenSize.height / 2 ))
        self.addChild(secondView!)
        view.addSubview((secondView?.view)!)
        secondView?.showDebugInfo(Testbed.getParameter(param: "debug_view") as! Bool)
        
        secondView?.view.center = CGPoint( x: screenSize.width/2, y: 3 * (screenSize.height/4) )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            
            let connection2 = R5Connection(config: config)
            
            self.subscribeStream2 = R5Stream(connection: connection2 )
            self.subscribeStream2!.delegate = self
            self.subscribeStream2?.client = self;
            
            self.secondView?.attach(self.subscribeStream2)
            
            self.subscribeStream2?.audioController = R5AudioController()
            
            self.subscribeStream2?.play(Testbed.getParameter(param: "stream2") as! String, withHardwareAcceleration:Testbed.getParameter(param: "hwaccel_on") as! Bool)
            
        }
    }
    
    @objc func onMetaData(data : String){
        
    }
    
    override func closeTest() {
        super.closeTest()
        
        if( self.subscribeStream2 != nil ){
            self.subscribeStream2!.stop()
        }
    }
}
