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
    var httpFormat = "http://%@:5080/socialpusher/api%@"
    
    @objc func doPush() {
        
        sendBtn?.isEnabled = false
        rtmpInput?.isHidden = true
        
        let host = (Testbed.getParameter(param: "host") as! String)
        let version = (Testbed.getParameter(param: "sm_version") as! String)
        let stream = Testbed.getParameter(param: "stream1") as! String
        
        let provision = String(format: provisionFormat, context, stream, rtmpInput!.text)
        
        let urlParams = generateParams(action: "provision.create")
        let forwardURL: String = String(format: httpFormat, originIP!, urlParams)
        if let encodedURL = forwardURL.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
            // Use encodedString
            print("Encoded string: \(encodedURL)")
            let url = "https://\(host)/as/\(version)/proxy/forward/?target=\(encodedURL)"
            let data = provision.data(using: String.Encoding.utf8)
            
            var req = NSURLRequest( url: NSURL(string: encodedURL)! as URL ) as URLRequest
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
        } else {
            print("Failed to encode the string.")
        }
    }
    
    @objc func doClose() {
        sendBtn?.isEnabled = false
        rtmpInput?.isHidden = true
        
        let host = (Testbed.getParameter(param: "host") as! String)
        let version = (Testbed.getParameter(param: "sm_version") as! String)
        let stream = Testbed.getParameter(param: "stream1") as! String
        
        let provision = String(format: provisionFormat, context, stream, rtmpInput!.text)
        
        let urlParams = generateParams(action: "provision.delete")
        let forwardURL: String = String(format: httpFormat, originIP!, urlParams)
        if let encodedURL = forwardURL.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
            // Use encodedString
            print("Encoded string: \(encodedURL)")
            let url = "https://\(host)/as/\(version)/proxy/forward/?target=\(encodedURL)"
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
        } else {
            print("Failed to encode the string.")
        }
    }
    
    // https://www.agnosticdev.com/content/how-use-commoncrypto-apis-swift-5
    func hashMessage(_ message: String) -> String {
        if let data = message.data(using: .utf8) {
            var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
            data.withUnsafeBytes {
                CC_SHA256($0.baseAddress, UInt32(data.count), &digest)
            }
             
            var hashed = ""
            for byte in digest {
                hashed += String(format:"%02x", UInt8(byte))
            }
            return hashed
        }
        return ""
    }
    
    func generateParams( action: String) -> String {
        
        let pass = (Testbed.getParameter(param: "cluster_password") as! String)
        let ts = Int(Date().timeIntervalSince1970)
        let signature = hashMessage("\(action)\(ts)\(pass)")
        return String(format: "?action=%@&timestamp=%@&signature=%@", action, String(ts), signature)
        
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
