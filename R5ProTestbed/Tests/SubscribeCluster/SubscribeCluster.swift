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
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let urlString = "http://" + (Testbed.getParameter("host") as! String) + ":5080/cluster"
        
        NSURLConnection.sendAsynchronousRequest(
            NSURLRequest( URL: NSURL(string: urlString)! ),
            queue: NSOperationQueue(),
            completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            
                if ((error) != nil) {
                    NSLog("%@", error!);
                    return;
                }
                
                //   Convert our response to a usable NSString
                let dataAsString = NSString( data: data!, encoding: NSUTF8StringEncoding)
                
                //   The string above is formatted like 99.98.97.96:1234, but we won't need the port portion
                let ip = dataAsString?.substringToIndex((dataAsString?.rangeOfString(":").location)!)
                NSLog("Retrieved %@ from %@, of which the usable IP is %@", dataAsString!, urlString, ip!);

                //   Setup a configuration object for our connection
                let config = R5Configuration()
                config.host = ip
                config.port = Int32(Testbed.getParameter("port") as! Int)
                config.contextName = Testbed.getParameter("context") as! String
                config.`protocol` = 1;
                config.buffer_time = Testbed.getParameter("buffer_time") as! Float
                
                //   Create a new connection using the configuration above
                let connection = R5Connection(config: config)
                
                //   UI updates must be asynchronous
                dispatch_async(dispatch_get_main_queue(), {
                    //   Create our new stream that will utilize that connection
                    self.subscribeStream = R5Stream(connection: connection)
                    
                    //   Setup our listener to handle events from this stream
                    self.subscribeStream!.delegate = self
                    self.subscribeStream?.client = self
                    
                    //   Setup our R5VideoViewController to display the stream content
                    self.setupDefaultR5VideoViewController()
                    
                    //   Attach the R5VideoViewController to our publishing stream
                    self.currentView?.attachStream(self.subscribeStream)
                    
                    //   Start subscribing!!
                    self.subscribeStream!.play(Testbed.getParameter("stream1") as! String)
                    
                    let label = UILabel(frame: CGRect(x: 0, y: self.view.frame.height-24, width: self.view.frame.width, height: 24))
                    label.textAlignment = NSTextAlignment.Left
                    label.backgroundColor = UIColor.lightGrayColor()
                    label.text = "Connected to: " + ip!
                    self.view.addSubview(label)
                })
            })
        
    }
    
}
