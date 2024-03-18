//
//  ConferenceStreamManagerTest.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 5/4/20.
//  Copyright © 2020 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(ConferenceStreamManagerTest)
class ConferenceStreamManagerTest: ConferenceTest {
    
    func delayRetryRequest (streamName: String, context: String, action: String, resolver: @escaping (_ ip: String) -> Void) {
        
        // 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("Retrying request for " + context + "/" + streamName)
            self.requestServer(streamName, context: context, action: action, resolve: resolver)
        }
        
    }
    
    func requestServer(_ streamName: String, context: String, action: String, resolve: @escaping (_ ip: String) -> Void) {
        
        print("Requesting for stream: " + streamName + " - and action= " + action)
        
        let host = (Testbed.getParameter(param: "host") as! String)
        let port = (Testbed.getParameter(param: "server_port") as! String)
        let portURI = port == "80" ? "" : ":" + port
        let version = (Testbed.getParameter(param: "sm_version") as! String)
        let nodeGroup = (Testbed.getParameter(param: "sm_nodegroup") as! String)
        let context = (Testbed.getParameter(param: "context") as! String)
        let streamName = (Testbed.getParameter(param: "stream1") as! String)
        
        let originURI = "\(host)\(portURI)/as/\(version)/streams/stream/\(nodeGroup)/\(action)/\(context)/\(streamName)"
        let url = (portURI.isEmpty ? "https://" : "http://") + originURI
        
        NSURLConnection.sendAsynchronousRequest(
            NSURLRequest( url: NSURL(string: url)! as URL ) as URLRequest,
            queue: OperationQueue(),
            completionHandler:{ (response: URLResponse?, data: Data?, error: Error?) -> Void in
                
                if ((error) != nil) {
                    print(error!)
                    return
                }
                
                //   The string above is in JSON format, we specifically need the serverAddress value
                var json: [String: AnyObject]
                do{
                    json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [String: AnyObject]
                } catch {
                    print(error)
                    return
                }
                
                if let ip = json["serverAddress"] as? String {
                    resolve(ip)
                }
                else if let errorMessage = json["errorMessage"] as? String {
                    print(AccessError.error(message: errorMessage))
                    self.delayRetryRequest(streamName: streamName, context: context, action: action, resolver: resolve)
                }
                
        })
    }
    
    override func publish() {
        let context = (Testbed.getParameter(param: "context") as! String) + "/" + roomName!
        requestServer(pubName as! String, context: context, action: "publish", resolve: { (url) in
            DispatchQueue.main.async {
                self.config?.host = url
                super.publish()
            }
        })
    }
    
    override func subscribe(toName : String) {
        let context = (Testbed.getParameter(param: "context") as! String) + "/" + roomName!
        requestServer(toName, context: context, action: "subscribe", resolve: { (url) in
            DispatchQueue.main.async {
                self.config?.host = url
                super.subscribe(toName: toName)
            }
        })
    }
}
