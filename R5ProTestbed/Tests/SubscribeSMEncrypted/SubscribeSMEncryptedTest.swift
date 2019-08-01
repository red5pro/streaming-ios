//
//  SubscribeSMEncryptedTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 1/9/19.
//  Copyright © 2019 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeSMEncryptedTest)
class SubscribeSMEncryptedTest: SubscribeStreamManagerTest {
    
    override func responder( urls: Array<String>) -> (String?, Error?) -> Void {
        var urls = urls
        return {(ip: String?, error: Error?) -> Void in
            
            if ((error) != nil) {
                if (urls.endIndex == urls.startIndex) {
                    NSLog("%@", String(error!.localizedDescription))
                    self.showInfo(title: "Error", message: String(error!.localizedDescription) + "\n\n" + "You may be trying to access over HTTPS which requires a Fully-Qualified Domain Name for host.\n\nYou will need to edit your host and port settings accordingly.")
                }
                else {
                    self.requestOrigin(urls.popLast()!, resolve: self.responder(urls: urls))
                }
                return;
            }
            
            //   Setup a configuration object for our connection
            let config = R5Configuration()
            config.host = ip
            config.port = Int32(Testbed.getParameter(param: "port") as! Int)
            config.contextName = Testbed.getParameter(param: "context") as! String
            
            //For stream encryption, this is the only line that needed to change from the basic SM example
            config.`protocol` = Int32(r5_srtp.rawValue)
            
            config.buffer_time = Testbed.getParameter(param: "buffer_time") as! Float
            config.licenseKey = Testbed.getParameter(param: "license_key") as! String
            
            //   Create a new connection using the configuration above
            let connection = R5Connection(config: config)
            
            //   UI updates must be asynchronous
            DispatchQueue.main.async(execute: {
                //   Create our new stream that will utilize that connection
                self.subscribeStream = R5Stream(connection: connection)
                self.subscribeStream!.delegate = self
                self.subscribeStream?.client = self;
                
                self.currentView?.attach(self.subscribeStream)
                
                self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String)
                
                let label = UILabel(frame: CGRect(x: 0, y: self.view.frame.height-24, width: self.view.frame.width, height: 24))
                label.textAlignment = NSTextAlignment.left
                label.backgroundColor = UIColor.lightGray
                label.text = "Connected to: " + ip!
                self.view.addSubview(label)
            })
            
        }
    }
    
}
