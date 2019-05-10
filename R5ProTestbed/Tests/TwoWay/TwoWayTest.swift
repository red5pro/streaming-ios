//
//  TwoWay.swift
//  R5ProTestbed
//
//  Created by David Heimann on 3/9/16.
//  Copyright © 2016 Infrared5. All rights reserved.
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
            
            self.subscribeStream!.play(Testbed.getParameter(param: "stream2") as! String)
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
    
    @objc func onMetaData(data : String){
        
    }
}
