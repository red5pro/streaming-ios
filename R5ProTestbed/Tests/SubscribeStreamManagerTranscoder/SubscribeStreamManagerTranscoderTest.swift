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
    
    var selectedStreamGuid: String? = nil
    var provisionList: Array<AnyObject>? = nil
    
    @objc func selectStream(sender: UITapGestureRecognizer) {
        
        let context = (Testbed.getParameter(param: "context") as! String)
        let streamName = (Testbed.getParameter(param: "stream1") as! String)
        let defaultGuid = "\(context)/\(streamName)_1"
        
        let button = sender.view as? UIButton
        let streamGuid = button?.title(for: UIControl.State.normal) ?? defaultGuid
        
        self.startSubscription(streamGuid: streamGuid)
        
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
    
    func startSubscription (streamGuid : String) {
        
        selectedStreamGuid = streamGuid
        
        let host = (Testbed.getParameter(param: "host") as! String)
        let port = (Testbed.getParameter(param: "server_port") as! String)
        let portURI = port == "80" ? "" : ":" + port
        let version = (Testbed.getParameter(param: "sm_version") as! String)
        let nodeGroup = (Testbed.getParameter(param: "sm_nodegroup") as! String)
        
        let edgeURI = "\(host)\(portURI)/as/\(version)/streams/stream/\(nodeGroup)/subscribe/\(streamGuid)"
        let httpString = "http://" + edgeURI
        let httpsString = "https://" + edgeURI
        
        var urls = [httpString, httpsString]
        requestEdge(urls.popLast()!, resolve: responder(urls: urls))
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
                var json: [[String: AnyObject]]
                do{
                    json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [[String: AnyObject]]
                }catch{
                    print(error)
                    return
                }
                
                if let edge = json.first {
                    if let ip = edge["serverAddress"] as? String {
                        NSLog("Retrieved %@ from %@, of which the usable IP is %@", dataAsString!, url, ip);
                        resolve(ip, error)
                    }
                    else if let errorMessage = edge["errorMessage"] as? String {
                        resolve(nil, AccessError.error(message: errorMessage))
                    }
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
            let hwAccel = Testbed.getParameter(param: "hwaccel_on") as! Bool
            
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
                
                let paths = self.selectedStreamGuid?.split(separator: "/")
                if let name = paths?.last {
                    
                    self.subscribeStream!.play(String(name), withHardwareAcceleration: hwAccel)
                    
                    let label = UILabel(frame: CGRect(x: 0, y: self.view.frame.height-24, width: self.view.frame.width, height: 24))
                    label.textAlignment = NSTextAlignment.left
                    label.backgroundColor = UIColor.lightGray
                    label.text = "Connected to: " + ip!
                    self.view.addSubview(label)
                    
                }
            })
            
        }
    }
    
    func requestProvision(streamGuid: String, token: String) {
        
        let host = (Testbed.getParameter(param: "host") as! String)
        let version = (Testbed.getParameter(param: "sm_version") as! String)
        let nodeGroup = (Testbed.getParameter(param: "sm_nodegroup") as! String)
        let url = "https://\(host)/as/\(version)/streams/provision/\(nodeGroup)/\(streamGuid)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
                // Handle response
            if let error = error {
                print("Error: \(error)")
                self.showInfo(title: "Error", message: String(error.localizedDescription))
                return
            }
            
            let dataAsString = NSString( data: data!, encoding: String.Encoding.utf8.rawValue)
            
            //   The string above is in JSON format, we specifically need the serverAddress value
            var json: [String: AnyObject]
            do{
                json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [String: AnyObject]
            }catch{
                print(error)
                return
            }
            
            if let streams = json["streams"] as? Array<AnyObject> {
                self.provisionList = streams
                //   UI updates must be asynchronous
                DispatchQueue.main.async(execute: {
                    var screenSize = self.view.bounds.size
                    if #available(iOS 11.0, *) {
                        screenSize =  self.view.safeAreaLayoutGuide.layoutFrame.size
                    }
                    var index = CGFloat(1.0)
                    for stream in streams {
                        let s = stream as! [String:AnyObject]
                        let sendBtn = UIButton(frame: CGRect(x: 20, y: (screenSize.height * 0.75) - (70*index), width: screenSize.width - 40, height: 60))
                        sendBtn.backgroundColor = UIColor.darkGray
                        sendBtn.setTitle(s["streamGuid"] as? String, for: UIControl.State.normal)
                        self.view.addSubview(sendBtn)
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.selectStream))
                        sendBtn.isUserInteractionEnabled = true
                        sendBtn.addGestureRecognizer(tap)
                        index = index + 1.0
                    }
                })
            }
            
        }
        task.resume()
        
    }
    
    func authenticate(host: String, username: String, password: String, resolve: @escaping (_ token: String?, _ error: Error?) -> Void) {
        let data = "\(username):\(password)".data(using: .utf8)!
        let base64String = data.base64EncodedString()
        let url = "https://\(host)/as/v1/auth/login"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PUT"
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
                // Handle response
            if let error = error {
                print("Error: \(error)")
                resolve(nil, error)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
                if let data = data {
                    // Handle data
                    print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
                    if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                        var json: [String: AnyObject]
                        do {
                            json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! [String: AnyObject]
                            if let errorMessage = json["errorMessage"] as? String {
                                resolve(nil, AccessError.error(message: errorMessage))
                            } else if let token = json["token"] as? String {
                                resolve(token, nil)
                            }
                        } catch {
                            self.showInfo(title: "Error", message: "Could not Authenticate to access Provisions.")
                            print(error)
                            return
                        }
                    } else {
                        self.showInfo(title: "Error", message: "Could not Authenticate to access Provisions.")
                        return
                    }
                }
            } else {
                resolve(nil, AccessError.error(message: "Could not complete request"))
            }
        }
        task.resume()
    }

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in };
        
        setupDefaultR5VideoViewController()
        
        let host = (Testbed.getParameter(param: "host") as! String)
        let username = (Testbed.getParameter(param: "sm_username") as! String)
        let password = (Testbed.getParameter(param: "sm_password") as! String)
        
        authenticate(host: host, username: username, password: password, resolve: { [self](token: String?, error: Error?) -> Void in
            
            if ((error) != nil) {
                NSLog("%@", String(error!.localizedDescription))
                self.showInfo(title: "Error", message: String(error!.localizedDescription))
                return
            }
            
            let app = (Testbed.getParameter(param: "context") as! String)
            let streamName = (Testbed.getParameter(param: "stream1") as! String)
            let streamGuid = "\(app)/\(streamName)"
            requestProvision(streamGuid: streamGuid, token: token!)
            
        })
    }
}
