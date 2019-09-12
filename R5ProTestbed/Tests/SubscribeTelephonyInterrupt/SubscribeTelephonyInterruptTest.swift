//
//  SubscribeTelephonyInterruptTest.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 21/02/2019.
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

@objc(SubscribeTelephonyInterruptTest)
class SubscribeTelephonyInterruptTest: BaseTest {
    
    var finished = false
    var publisherIsInBackground = false
    var publisherIsDisconnected = false
    
    override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        NSLog("Status: %s ", r5_string_for_status(statusCode))
        let s =  String(format: "Status: %s (%@)",  r5_string_for_status(statusCode), msg)
        ALToastView.toast(in: self.view, withText:s)
        
        if (Int(statusCode) == Int(r5_status_disconnected.rawValue)) {
            self.cleanup()
        } else if (Int(statusCode) == Int(r5_status_netstatus.rawValue) && msg == "NetStream.Play.UnpublishNotify") {
            
            // publisher has unpublished. possibly from background/interrupt.
            if (publisherIsInBackground) {
                publisherIsDisconnected = true
                // Begin reconnect sequence...
                let view = currentView
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if(self.subscribeStream != nil) {
                        view?.attach(nil)
                        self.subscribeStream?.delegate = nil;
                        self.subscribeStream!.stop()
                    }
                    self.reconnect()
                }
            }
            
        }
    }
    
    func Subscribe(_ name: String) {
        
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
        self.subscribeStream?.client = self;
        
        currentView?.attach(subscribeStream)
        
        self.subscribeStream!.play(name)
        
    }
    
    func publisherBackground(msg: String) {
        NSLog("(publisherBackground) the msg: %@", msg)
        publisherIsInBackground = true
        ALToastView.toast(in: self.view, withText:"Publish Background")
    }
    
    func publisherForeground(msg: String) {
        NSLog("(publisherForeground) the msg: %@", msg)
        publisherIsInBackground = false
        ALToastView.toast(in: self.view, withText:"Publisher Foreground")
    }
    
    func publisherInterrupt(msg: String) {
        // Most likely will not receive this...
        NSLog("(publisherInterrupt) the msg: %@", msg)
        publisherIsDisconnected = true
        ALToastView.toast(in: self.view, withText:"Publisher Interrupt")
        
        // Begin reconnect sequence...
        let view = currentView
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if(self.subscribeStream != nil) {
                view?.attach(nil)
                self.subscribeStream?.delegate = nil;
                self.subscribeStream!.stop()
            }
            self.reconnect()
        }
    }
    
    func findStreams() {
        
        let domain = Testbed.getParameter(param: "host") as! String
        let app = Testbed.getParameter(param: "context") as! String
        let urlPath = "http://" + domain + ":5080" + "/" + app + "/streams.jsp"
        let streamName = Testbed.getParameter(param: "stream1") as! String
        
        var request = URLRequest(url: URL(string: urlPath)!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        NSLog("Requesting stream list...")
        
        session.dataTask(with: request) {data, response, err in
            
            if err == nil {
                //                let resut = data as String
                do {
                    NSLog("Stream list received...")
                    //   Convert our response to a usable NSString
                    let list = try JSONSerialization.jsonObject(with: data!) as! Array<Dictionary<String, String>>;
                    
                    var exists: Bool = false;
                    for dict:Dictionary<String, String> in list {
                        if(dict["name"] == streamName){
                            exists = true;
                            break;
                        }
                    }
                    DispatchQueue.main.async {
                        if (exists) {
                            NSLog("Publisher exists, let's try connecting...")
                            self.Subscribe(streamName)
                        }
                        else {
                            NSLog("Publisher does not exist.")
                            self.reconnect()
                        }
                    }
                    
                }
                catch let error as NSError {
                    NSLog(error.localizedFailureReason!)
                }
            }
            else {
                NSLog(err!.localizedDescription)
            }
            
            }.resume()
        
    }
    
    func reconnect () {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if self.finished {
                return
            }
            self.findStreams()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.finished = true
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupDefaultR5VideoViewController()
        findStreams()
    }
    
    override func viewDidLoad() {
        self.finished = false
        super.viewDidLoad()
    }
    
}

