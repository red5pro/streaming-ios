//
//  SubscribeStreamManagerTranscoderTest.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 22/11/2019.
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

@objc(SubscribeStreamManagerTranscoderTest)
class SubscribeStreamManagerTranscoderTest : BaseTest {
    
    var selectedStreamName: String? = nil
    var provisionList: Array<AnyObject>? = nil
    
    func startSubscription (name : String) {
        let port = (Testbed.getParameter(param: "server_port") as! String)
        let portURI = (port == "80" || port == "443") ? "" : ":" + port
        let version = (Testbed.getParameter(param: "sm_version") as! String)
        let edgeURI = (Testbed.getParameter(param: "host") as! String) + portURI + "/streammanager/api/" + version + "/event/" +
            (Testbed.getParameter(param: "context") as! String) + "/" +
            name + "?action=subscribe"
        let httpString = "http://" + edgeURI
        let httpsString = "https://" + edgeURI
        
        var urls = [httpString, httpsString]
        
        selectedStreamName = name
        requestEdge(urls.popLast()!, resolve: responder(urls: urls))
    }
    
    @objc func selectStream(sender: UITapGestureRecognizer) {
        
        let streamName = (Testbed.getParameter(param: "stream1") as? String)
        let button = sender.view as? UIButton
        let name = button?.title(for: UIControl.State.normal) ?? streamName! + "_1"
        
        self.startSubscription(name: name)
        
        for uibutton in self.view.subviews {
            if let btn = uibutton as? UIButton {
                btn.isEnabled = false
            }
        }
        
    }
    
    func showInfo(title: String, message: String){
        DispatchQueue.main.async(execute: {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                // Trying to redirect user to details form...
                //            controller?.performSegue(withIdentifier: "showDetail", sender: test)
            }))
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    func requestEdge(_ url: String, resolve: @escaping (_ ip: String?, _ error: Error?) -> Void) {
        
        NSURLConnection.sendAsynchronousRequest(
            NSURLRequest( url: NSURL(string: url)! as URL ) as URLRequest,
            queue: OperationQueue(),
            completionHandler:{ (response: URLResponse?, data: Data?, error: Error?) -> Void in
                
                if ((error) != nil) {
                    resolve(nil, error)
                    return
                }
                
                //   Convert our response to a usable NSString
                let dataAsString = NSString( data: data!, encoding: String.Encoding.utf8.rawValue)
                
                //   The string above is in JSON format, we specifically need the serverAddress value
                var json: [String: AnyObject]
                do{
                    json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [String: AnyObject]
                }catch{
                    print(error)
                    return
                }
                
                if let ip = json["serverAddress"] as? String {
                    NSLog("Retrieved %@ from %@, of which the usable IP is %@", dataAsString!, url, ip);
                    resolve(ip, error)
                }
                else if let errorMessage = json["errorMessage"] as? String {
                    resolve(nil, AccessError.error(message: errorMessage))
                }
                
        })
        
    }
    
    func responder( urls: Array<String>) -> (String?, Error?) -> Void {
        var urls = urls
        return {(ip: String?, error: Error?) -> Void in
            
            if ((error) != nil) {
                if (urls.endIndex == urls.startIndex) {
                    NSLog("%@", String(error!.localizedDescription))
                    self.showInfo(title: "Error", message: String(error!.localizedDescription) + "\n\n" + "You may be trying to access over HTTPS which requires a Fully-Qualified Domain Name for host.\n\nYou will need to edit your host and port settings accordingly.")
                }
                else {
                    self.requestEdge(urls.popLast()!, resolve: self.responder(urls: urls))
                }
                return;
            }
            
            //   Setup a configuration object for our connection
            let config = R5Configuration()
            config.host = ip
            config.port = Int32(Testbed.getParameter(param: "port") as! Int)
            config.contextName = Testbed.getParameter(param: "context") as! String
            config.`protocol` = 1;
            config.buffer_time = Testbed.getParameter(param: "buffer_time") as! Float
            config.licenseKey = Testbed.getParameter(param: "license_key") as! String
            
            //   Create a new connection using the configuration above
            let connection = R5Connection(config: config)
            
            //   UI updates must be asynchronous
            DispatchQueue.main.async(execute: {
                
                for uibutton in self.view.subviews {
                    if let btn = uibutton as? UIButton {
                        btn.removeFromSuperview()
                    }
                }
                
                //   Create our new stream that will utilize that connection
                self.subscribeStream = R5Stream(connection: connection)
                self.subscribeStream!.delegate = self
                self.subscribeStream?.client = self;
                
                self.currentView?.attach(self.subscribeStream)
                
                self.subscribeStream!.play(self.selectedStreamName!, withHardwareAcceleration:Testbed.getParameter(param: "hwaccel_on") as! Bool)
                
                let label = UILabel(frame: CGRect(x: 0, y: self.view.frame.height-24, width: self.view.frame.width, height: 24))
                label.textAlignment = NSTextAlignment.left
                label.backgroundColor = UIColor.lightGray
                label.text = "Connected to: " + ip!
                self.view.addSubview(label)
            })
            
        }
    }
    
    func requestProvisions(_ url: String, resolve: @escaping (_ streams: Array<AnyObject>?, _ error: Error?) -> Void) {
        
        var req = NSURLRequest( url: NSURL(string: url)! as URL ) as URLRequest
        NSURLConnection.sendAsynchronousRequest(
            req,
            queue: OperationQueue(),
            completionHandler:{ (response: URLResponse?, data: Data?, error: Error?) -> Void in
                
                if ((error) != nil) {
                    resolve(nil, error)
                    return
                }
                
                //   Convert our response to a usable NSString
                let dataAsString = NSString( data: data!, encoding: String.Encoding.utf8.rawValue)
                
                //   The string above is in JSON format, we specifically need the serverAddress value
                var json: [String: AnyObject]
                do {
                    json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [String: AnyObject]
                } catch {
                    print(error)
                    return
                }
                
                var streams : Array<AnyObject>? = nil
                
                if let errorMessage = json["errorMessage"] as? String {
                    resolve(nil, AccessError.error(message: errorMessage))
                    return
                }
                else if let data = json["data"] as? [String:AnyObject]{
                    
                    if let metaNode = data["meta"] as? [String:AnyObject] {
                        streams = metaNode["stream"] as? Array<AnyObject>
                    }
                }
                else if let metaRoot = json["meta"] as? [String:AnyObject] {
                    streams = metaRoot["stream"] as? Array<AnyObject>
                }
                
                if (streams != nil) {
                    resolve(streams, error)
                } else {
                    resolve(nil, AccessError.error(message: "No streams found."))
                }
                
        })
        
    }
    
    func respondToProvisions(urls: Array<String>) -> (Array<AnyObject>?, Error?) -> Void {
        var urls = urls
        return {(streams: Array<AnyObject>?, error: Error?) -> Void in
            
            if ((error) != nil) {
                if (urls.endIndex == urls.startIndex) {
                    NSLog("%@", String(error!.localizedDescription))
                    self.showInfo(title: "Error", message: String(error!.localizedDescription) + "\n\n" + "You may be trying to access over HTTPS which requires a Fully-Qualified Domain Name for host.\n\nYou will need to edit your host and port settings accordingly.")
                }
                else {
                    self.requestProvisions(urls.popLast()!, resolve: self.respondToProvisions(urls: urls))
                }
                return;
            }
            
            self.provisionList = streams
            //   UI updates must be asynchronous
            DispatchQueue.main.async(execute: {
                let screenSize = UIScreen.main.bounds.size
                var index = CGFloat(1.0)
                for stream in streams! {
                    let s = stream as! [String:AnyObject]
                    let sendBtn = UIButton(frame: CGRect(x: 20, y: (screenSize.height * 0.75) - (70*index), width: screenSize.width - 40, height: 60))
                    sendBtn.backgroundColor = UIColor.darkGray
                    sendBtn.setTitle(s["name"] as! String, for: UIControl.State.normal)
                    self.view.addSubview(sendBtn)
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.selectStream))
                    sendBtn.addGestureRecognizer(tap)
                    index = index + 1.0
                }
            })
            
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in };
        
        setupDefaultR5VideoViewController()
        
        let port = (Testbed.getParameter(param: "server_port") as! String)
        let portURI = (port == "80" || port == "443") ? "" : ":" + port
        let version = (Testbed.getParameter(param: "sm_version") as! String)
        let accessToken = (Testbed.getParameter(param: "sm_access_token") as! String)
        let edgeURI = (Testbed.getParameter(param: "host") as! String) + portURI + "/streammanager/api/" + version + "/admin/event/meta/" +
            (Testbed.getParameter(param: "context") as! String) + "/" +
            (Testbed.getParameter(param: "stream1") as! String) + "?action=subscribe&accessToken=" + accessToken
            
        let httpString = "http://" + edgeURI
        let httpsString = "https://" + edgeURI
        
        var urls = [httpString, httpsString]
        
        requestProvisions(urls.popLast()!, resolve: respondToProvisions(urls: urls))
        
    }

}
