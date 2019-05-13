//
//  SubscribeTestViewController.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/16/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeAutoReconnectTest)
class SubscribeAutoReconnectTest: BaseTest {
    
    var finished = false
    
    override func viewWillDisappear(_ animated: Bool) {
        self.finished = true
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        self.finished = false
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
        
        self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String)
        
    }
    
    override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        
        super.onR5StreamStatus(stream, withStatus: statusCode, withMessage: msg)
        
        if(statusCode == Int32(r5_status_connection_error.rawValue) ||
            statusCode == Int32(r5_status_connection_close.rawValue)) {
            
            //we can assume it failed here!
        
            NSLog("Connection error")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if self.finished {
                    return
                }
                NSLog("Subscribing again!!")
                self.Subscribe()
            }
            
        }
        else if (statusCode == Int32(r5_status_netstatus.rawValue) && msg == "NetStream.Play.UnpublishNotify") {
            
            // publisher stopped broadcast. let's resume autoconnect logic.
            let view = currentView
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if(self.subscribeStream != nil) {
                    view?.attach(nil)
                    self.subscribeStream!.stop()
                    self.subscribeStream = nil
                }
                
                if self.finished {
                    return
                }
                NSLog("Subscribing again!!")
                self.Subscribe()
            }
        }
        
    }
    
    
    @objc func onMetaData(data : String){
        
    }
    
    
    
}
