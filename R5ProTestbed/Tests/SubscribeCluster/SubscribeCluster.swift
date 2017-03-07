//
//  SubscribeCluster.swift
//  R5ProTestbed
//
//  Created by David Heimann on 3/21/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeCluster)
class SubscribeCluster: BaseTest {
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let urlString = "http://" + (Testbed.getParameter(param: "host") as! String) + ":5080/cluster"
        
        NSURLConnection.sendAsynchronousRequest(
            NSURLRequest( url: NSURL(string: urlString)! as URL ) as URLRequest,
            queue: OperationQueue(),
            completionHandler:{ (response: URLResponse?, data: Data?, error: Error?) -> Void in
            
                if ((error) != nil) {
                    NSLog("%@", error! as NSError);
                    return;
                }
                
                //   Convert our response to a usable NSString
                let dataAsString = NSString( data: data!, encoding: String.Encoding.utf8.rawValue)
                
                //   The string above is formatted like 99.98.97.96:1234, but we won't need the port portion
                let ip = dataAsString?.substring(to: (dataAsString?.range(of: ":").location)!)
                NSLog("Retrieved %@ from %@, of which the usable IP is %@", dataAsString!, urlString, ip!);

                //   Setup a configuration object for our connection
                let config = R5Configuration()
                config.host = ip
                config.port = Int32(Testbed.getParameter(param: "port") as! Int)
                config.contextName = Testbed.getParameter(param: "context") as! String
                config.`protocol` = 1;
                config.buffer_time = Testbed.getParameter(param: "buffer_time") as! Float
                
                //   Create a new connection using the configuration above
                let connection = R5Connection(config: config)
                
                //   UI updates must be asynchronous
                DispatchQueue.main.async(execute: {
                    //   Create our new stream that will utilize that connection
                    self.subscribeStream = R5Stream(connection: connection)
                    
                    //   Setup our listener to handle events from this stream
                    self.subscribeStream!.delegate = self
                    self.subscribeStream?.client = self
                    
                    //   Setup our R5VideoViewController to display the stream content
                    self.setupDefaultR5VideoViewController()
                    
                    //   Attach the R5VideoViewController to our publishing stream
                    self.currentView?.attach(self.subscribeStream)
                    
                    //   Start subscribing!!
                    self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String)
                    
                    let label = UILabel(frame: CGRect(x: 0, y: self.view.frame.height-24, width: self.view.frame.width, height: 24))
                    label.textAlignment = NSTextAlignment.left
                    label.backgroundColor = UIColor.lightGray
                    label.text = "Connected to: " + ip!
                    self.view.addSubview(label)
                })
            })
        
    }
    
}
