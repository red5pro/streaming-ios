//
//  SubscribeTestViewController.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/16/15.
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

@objc(SubscribeAutoReconnectTest)
class SubscribeAutoReconnectTest: BaseTest {
    
    var finished = false
    var retryTimer: Timer?
    static let RETRY_TIMEOUT: Float = 2.0
    
    override func viewWillDisappear(_ animated: Bool) {
        self.finished = true
        if (self.retryTimer != nil) {
            self.retryTimer?.invalidate()
        }
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        self.finished = false
        if (self.retryTimer != nil) {
            self.retryTimer?.invalidate()
        }
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        setupDefaultR5VideoViewController()
        
        self.Subscribe()
        
    }
    
    func Subscribe(){
        
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
        self.subscribeStream?.client = self;
        
        currentView?.attach(subscribeStream)
        
        self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String, withHardwareAcceleration:Testbed.getParameter(param: "hwaccel_on") as! Bool)
        
    }
    
    override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        
        super.onR5StreamStatus(stream, withStatus: statusCode, withMessage: msg)
        
        if(statusCode == Int32(r5_status_connection_error.rawValue) ||
            statusCode == Int32(r5_status_connection_close.rawValue) ||
            statusCode == Int32(r5_status_disconnected.rawValue)) {
            
            //we can assume it failed here!
        
            NSLog("Connection error")
            if let timer = self.retryTimer {
                timer.invalidate()
            }
            self.retryTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(SubscribeAutoReconnectTest.RETRY_TIMEOUT), repeats: false) { [weak self] timer in
                
                if (!self!.finished) {
                    NSLog("Subscribing again!!")
                    self!.Subscribe()
                }
                
            }
            
        }
        else if (statusCode == Int32(r5_status_netstatus.rawValue) && msg == "NetStream.Play.UnpublishNotify") {
            
            // publisher stopped broadcast. let's resume autoconnect logic.
            let view = currentView
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if(self.subscribeStream != nil) {
//                    view?.attach(nil)
                    self.subscribeStream!.stop()
                    self.subscribeStream = nil
                }
                
                if let timer = self.retryTimer {
                    timer.invalidate()
                }
                self.retryTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(SubscribeAutoReconnectTest.RETRY_TIMEOUT), repeats: false) { [weak self] timer in
                    
                    if (!self!.finished) {
                        NSLog("Subscribing again!!")
                        self!.Subscribe()
                    }
                    
                }
            }
        }
        
    }
    
    
    @objc func onMetaData(data : String){
        
    }
    
    
    
}
