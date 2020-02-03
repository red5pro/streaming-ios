//
//  TwoWay.swift
//  R5ProTestbed
//
//  Created by David Heimann on 3/9/16.
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

@objc(TwoWayTest)
class TwoWayTest: BaseTest {
    var publishView : R5VideoViewController? = nil
    var timer : Timer? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in };
        
        setupDefaultR5VideoViewController()
        
        
        publishView = getNewR5VideoViewController(rect: self.view.frame);
        self.addChild(publishView!);
        
        view.addSubview(publishView!.view)
        
        publishView!.showPreview(true)
        
        publishView!.showDebugInfo(Testbed.getParameter(param: "debug_view") as! Bool)
        
        // Set up the configuration
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        
        setupPublisher(connection: connection!)
        // show preview and debug info
        
        publishView!.attach(publishStream!)
        
        let screenSize = UIScreen.main.bounds.size
        let newFrame = CGRect(x: screenSize.width * (3/5), y: screenSize.height * (3/5), width: screenSize.width * (2/5), height: screenSize.height * (2/5) )
        publishView?.view.frame = newFrame
        
        self.publishStream?.client = self;
        self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: R5RecordTypeLive)
    }
    
    @objc func subscribeBegin()
    {
        performSelector(onMainThread: #selector(subscribeTrigger), with: nil, waitUntilDone: false)
    }
    
    @objc func subscribeTrigger()
    {
        if( subscribeStream == nil )
        {
            let config = getConfig()
            // Set up the connection and stream
            let connection = R5Connection(config: config)
            self.subscribeStream = R5Stream(connection: connection)
            self.subscribeStream!.delegate = self
            self.subscribeStream?.client = self;
            
            currentView?.attach(subscribeStream)
            
            self.subscribeStream!.play(Testbed.getParameter(param: "stream2") as! String, withHardwareAcceleration:Testbed.getParameter(param: "hwaccel_on") as! Bool)
        }
    }
    var failCount: Int = 0;
    override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        
        if(stream == self.publishStream){
            
            if(Int(statusCode) == Int(r5_status_start_streaming.rawValue)){
                
                self.timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(getStreams), userInfo: nil, repeats: false)
            }
        }
        
        if(stream == self.subscribeStream){
            if(Int(statusCode) == Int(r5_status_connection_error.rawValue)){
                failCount += 1
                if(failCount < 4){
                    self.timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(subscribeBegin), userInfo: nil, repeats: false)
                    self.subscribeStream = nil
                }
                else{
                    print("The other stream appears to be invalid")
                }
            }
        }
    }
    
    @objc func getStreams (){
        publishStream?.connection.call("streams.getLiveStreams", withReturn: "onGetLiveStreams", withParam: nil)
    }
    
    @objc func onGetLiveStreams (streams : String){
        
        NSLog("Got streams: " + streams)
        
        var names : NSArray
        
        do{
            names = try JSONSerialization.jsonObject(with: streams.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
        } catch _ {
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getStreams), userInfo: nil, repeats: false)
            return
        }
        
        for i in 0..<names.count {
            
            if( Testbed.getParameter(param: "stream2") as! String == names[i] as! String )
            {
                subscribeBegin()
                return
            }
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getStreams), userInfo: nil, repeats: false)
    }
    
    override func closeTest() {
        
        if(self.timer != nil){
            self.timer?.invalidate()
        }
        
        super.closeTest()
    }
    
    @objc func onMetaData(data : String){
        
    }
}
