//
//  PublishSocialPushTest.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 9/30/20.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import CommonCrypto
import R5Streaming

@objc(PublishStreamManagerSocialPushTest)
class PublishStreamManagerSocialPushTest: PublishStreamManagerTest, UITextViewDelegate {
    
    var rtmpInput : UITextView?
    var sendBtn : UIButton?
    var host : String = ""
    var context : String = ""
    var tap : UITapGestureRecognizer?
    
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
        
        let screenSize = UIScreen.main.bounds.size
        
        rtmpInput = UITextView(frame: CGRect(x: 0, y: screenSize.height - 50, width: (screenSize.width * 0.6) - 50, height: 24) )
        rtmpInput?.backgroundColor = UIColor.lightGray
        rtmpInput?.isEditable = true
        rtmpInput?.delegate = self
        
        host = Testbed.getParameter(param: "host") as! String
        context = Testbed.getParameter(param: "context") as! String
//        let stream2 = Testbed.getParameter(param: "stream2") as! String
//        rtmpInput?.text = String(format: "rtmp://%@:1935/%@/%@", host, context, stream2)
        rtmpInput?.text = String(format: "%@", Testbed.getParameter(param: "push_target") as! String)
        
        view.addSubview(rtmpInput!)
        
        sendBtn = UIButton(frame: CGRect(x: (screenSize.width * 0.6) - 50, y: screenSize.height - 50, width: 50, height: 24))
        sendBtn?.backgroundColor = UIColor.darkGray
        sendBtn?.isEnabled = false
        sendBtn?.setTitle("Waiting", for: UIControl.State.normal)
        sendBtn?.setTitle("Waiting", for: UIControl.State.disabled)
        view.addSubview(sendBtn!)
    }
    
    func setPush() {
        rtmpInput?.isHidden = false
        sendBtn?.setTitle("Push", for: UIControl.State.normal)
        sendBtn?.setTitle("Push", for: UIControl.State.disabled)
        if(tap != nil){
            sendBtn?.removeGestureRecognizer(tap!)
        }
        tap = UITapGestureRecognizer(target: self, action: #selector(doPush))
        sendBtn?.addGestureRecognizer(tap!)
    }
    
    func setClose() {
        sendBtn?.setTitle("Close", for: UIControl.State.normal)
        sendBtn?.setTitle("Close", for: UIControl.State.disabled)
        if(tap != nil){
            sendBtn?.removeGestureRecognizer(tap!)
        }
        tap = UITapGestureRecognizer(target: self, action: #selector(doClose))
        sendBtn?.addGestureRecognizer(tap!)
    }
    
    override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        super.onR5StreamStatus(stream, withStatus: statusCode, withMessage: msg)
        
        if( Int(statusCode) == Int(r5_status_start_streaming.rawValue) ){
            DispatchQueue.main.async(execute: {
                self.setPush()
                self.sendBtn?.isEnabled = true
            })
        }
    }
    
    var provisionFormat = """
            {
                "provisions":[
                    {
                        "guid":"any",
                        "level":1,
                        "context":"%@",
                        "name":"%@",
                        "parameters":{
                            "destURI":"%@"
                        }
                    }
                ]
            }
        """
    var httpFormat = "http://%@:%@/streammanager/api/%@/socialpusher%@"
    var httpsFormat = "https://%@/streammanager/api/%@/socialpusher%@"
    
    @objc func doPush() {
        sendBtn?.isEnabled = false
        rtmpInput?.isHidden = true
        //make call
        let stream = Testbed.getParameter(param: "stream1") as! String
        let provision = String(format: provisionFormat, context, stream, rtmpInput!.text)
        
        let urlParams = generateParams(action: "provision.create")
        let port = Testbed.getParameter(param: "server_port") as! String
        
        let smApi = Testbed.getParameter(param: "sm_version") as! String
        
        var url: String
        if(port == "443"){
            url = String(format: httpsFormat, host, smApi, urlParams)
        }
        else{
            url = String(format: httpFormat, host, port, smApi, urlParams)
        }
        
        let data = provision.data(using: String.Encoding.utf8)
        
        var req = NSURLRequest( url: NSURL(string: url)! as URL ) as URLRequest
        req.httpMethod = "POST"
        req.setValue("\(data!.count)", forHTTPHeaderField: "Content-Length")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = data
        
        NSLog("Calling %@ with params: %@", url, provision)
        
        NSURLConnection.sendAsynchronousRequest(
            req,
            queue: OperationQueue(),
            completionHandler:{ (response: URLResponse?, data: Data?, error: Error?) -> Void in
                
                if(data != nil){
                    let dataAsString = NSString( data: data!, encoding: String.Encoding.utf8.rawValue)
                    NSLog("Recieved Response: %@", dataAsString!)
                }
                
                if (error != nil) {
                    NSLog("recieved error: %@", error!.localizedDescription)
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    self.setClose()
                    self.sendBtn?.isEnabled = true
                })
            }
        )
    }
    
    @objc func doClose() {
        sendBtn?.isEnabled = false
        rtmpInput?.isHidden = true
        //make call
        let stream = Testbed.getParameter(param: "stream1") as! String
        let provision = String(format: provisionFormat, context, stream, rtmpInput!.text)
        
        let urlParams = generateParams(action: "provision.delete")
        let port = Testbed.getParameter(param: "server_port") as! String
        
        let smApi = Testbed.getParameter(param: "sm_version") as! String
        
        var url: String
        if(port == "443"){
            url = String(format: httpsFormat, host, smApi, urlParams)
        }
        else{
            url = String(format: httpFormat, host, port, smApi, urlParams)
        }
        
        let data = provision.data(using: String.Encoding.utf8)
        
        var req = NSURLRequest( url: NSURL(string: url)! as URL ) as URLRequest
        req.httpMethod = "POST"
        req.setValue("\(data!.count)", forHTTPHeaderField: "Content-Length")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = data
        
        NSLog("Calling %@ with params: %@", url, provision)
        
        NSURLConnection.sendAsynchronousRequest(
            req,
            queue: OperationQueue(),
            completionHandler:{ (response: URLResponse?, data: Data?, error: Error?) -> Void in
                
                if(data != nil){
                    let dataAsString = NSString( data: data!, encoding: String.Encoding.utf8.rawValue)
                    NSLog("Recieved Response: %@", dataAsString!)
                }
                
                if (error != nil) {
                    NSLog("recieved error: %@", error!.localizedDescription)
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    self.setPush()
                    self.sendBtn?.isEnabled = true
                })
            }
        )
    }
    
    func generateParams( action: String) -> String {
        
        let token = Testbed.getParameter(param: "sm_access_token") as! String
        
        return String(format: "?accessToken=%@&action=%@", token, action)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let screenSize = UIScreen.main.bounds.size
        
        rtmpInput?.frame = CGRect(x:0, y:screenSize.height * 0.5, width: (screenSize.width * 0.6) - 50, height: 24)
        sendBtn?.frame = CGRect(x: (screenSize.width * 0.6) - 50, y: screenSize.height * 0.5, width: 50, height: 24)
    }
    
    @objc func textViewDidEndEditing(_ textView: UITextView) {
        
        view.endEditing(true)
        
        let screenSize = UIScreen.main.bounds.size
        
        rtmpInput?.frame = CGRect(x:0, y: screenSize.height - 24, width: (screenSize.width * 0.6) - 50, height: 24)
        sendBtn?.frame = CGRect(x: (screenSize.width * 0.6) - 50, y: screenSize.height - 24, width: 50, height: 24)
        
        rtmpInput?.resignFirstResponder()
    }
}
