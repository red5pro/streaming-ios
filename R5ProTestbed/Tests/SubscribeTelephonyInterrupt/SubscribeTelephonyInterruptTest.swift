//
//  SubscribeTelephonyInterruptTest.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 21/02/2019.
//  Copyright © 2019 Infrared5. All rights reserved.
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
            }
            
        }
    }
    
    func Subscribe(_ name: String) {
        
        setupDefaultR5VideoViewController()
        
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
        ALToastView.toast(in: self.view, withText:"publishBackground: \(msg)")
    }
    
    func publisherForeground(msg: String) {
        NSLog("(publisherForeground) the msg: %@", msg)
        publisherIsInBackground = false
        ALToastView.toast(in: self.view, withText:"publisherForeground: \(msg)")
    }
    
    func publisherInterrupt(msg: String) {
        NSLog("(publisherInterrupt) the msg: %@", msg)
        publisherIsDisconnected = true
        ALToastView.toast(in: self.view, withText:"publisherInterrupt: \(msg)")
        
        // Begin reconnect sequence...
        reconnect()
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
    
    override func viewDidLoad() {
        self.finished = false
        super.viewDidLoad()
        findStreams()
    }
    
}

