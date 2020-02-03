//
//  PublishStreamManagerTranscodeTest.swift
//  R5ProTestbed
//
//  Created by Todd Anderson 07/25/2018.
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

@objc(PublishStreamManagerTranscodeTest)
class PublishStreamManagerTranscodeTest: BaseTest, UITextFieldDelegate, PublishTranscoderFormDelegate {
    
    var provisionList: Array<AnyObject>? = nil
    
    func showInfo(title: String, message: String){
        DispatchQueue.main.async(execute: {
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                // Trying to redirect user to details form...
                //            controller?.performSegue(withIdentifier: "showDetail", sender: test)
            }))
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    func setupPublisherWithVariant(connection: R5Connection, variant: [String : Any]) {
            
        let fpsVariants = Array<Int32>(Testbed.localParameters!["fps"] as! Array)
        self.publishStream = R5Stream(connection: connection)
        self.publishStream!.delegate = self
        
        if(Testbed.getParameter(param: "video_on") as! Bool){
            let props : [String : Any] = variant["properties"] as! [String : Any]
            // Attach the video from camera to stream
            let videoDevice = AVCaptureDevice.devices(for: AVMediaType.video).last as? AVCaptureDevice
            
                let camera = R5Camera(device: videoDevice, andBitRate: Int32(props["videoBR"] as! Int) / 1000)
           // Not relying on available Frame Rate Ranges, instead use local properties.
//          var fpsList = [1:60.0, 2:30.0, 3:15.0]
//            let range = videoDevice?.activeFormat.videoSupportedFrameRateRanges;
//            if variant["level"] as! Int == 1 {
//                fpsList[0] = range?[0].maxFrameRate
//            }
            // High (0): 60, Medium (1): 30, Low (2): 15
            camera?.fps = fpsVariants[(variant["level"] as! Int) - 1]
            camera?.width = Int32(props["videoWidth"] as! Int)
            camera?.height = Int32(props["videoHeight"] as! Int)
            camera?.orientation = 90
            self.publishStream!.attachVideo(camera)
        }
        if(Testbed.getParameter(param: "audio_on") as! Bool){
            // Attach the audio from microphone to stream
            let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
            let microphone = R5Microphone(device: audioDevice)
            microphone?.bitrate = 32
            NSLog("Got device %@", String(describing: audioDevice?.localizedName))
            self.publishStream!.attachAudio(microphone)
        }

    }
    
    func postProvisions(_ url: String, data: [String : Any], resolve: @escaping (_ streams: Array<AnyObject>?, _ error: Error?) -> Void) {
//        JSONEncoder().encode(data)
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        var req = NSURLRequest( url: NSURL(string: url)! as URL ) as URLRequest
        req.httpMethod = "POST"
        req.setValue("\(jsonData!.count)", forHTTPHeaderField: "Content-Length")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = jsonData
        
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
                    json = try JSONSerialization.jsonObject(with: data!, options:  JSONSerialization.ReadingOptions()) as! [String: AnyObject]
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
    
    func respondToProvisions(data: [String : Any], urls: Array<String>) -> (Array<AnyObject>?, Error?) -> Void {
        var urls = urls
        return {(streams: Array<AnyObject>?, error: Error?) -> Void in
            
            if ((error) != nil) {
                if (urls.endIndex == urls.startIndex) {
                    NSLog("%@", String(error!.localizedDescription))
                    self.showInfo(title: "Error", message: String(error!.localizedDescription) + "\n\n" + "You may be trying to access over HTTPS which requires a Fully-Qualified Domain Name for host.\n\nYou will need to edit your host and port settings accordingly.")
                }
                else {
                    self.postProvisions(urls.popLast()!, data: data, resolve: self.respondToProvisions(data: data, urls: urls))
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
    
    func requestOrigin(_ url: String, resolve: @escaping (_ ip: String?, _ error: Error?) -> Void) {
        
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
                do {
                    json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [String: AnyObject]
                } catch {
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
    
    func respondToOrigin(urls: Array<String>, streamName: String) -> (String?, Error?) -> Void {
        var urls = urls
        return {(ip: String?, error: Error?) -> Void in
            
            if ((error) != nil) {
                if (urls.endIndex == urls.startIndex) {
                    NSLog("%@", String(error!.localizedDescription))
                    self.showInfo(title: "Error", message: String(error!.localizedDescription) + "\n\n" + "You may be trying to access over HTTPS which requires a Fully-Qualified Domain Name for host.\n\nYou will need to edit your host and port settings accordingly.")
                }
                else {
                    self.requestOrigin(urls.popLast()!, resolve: self.respondToOrigin(urls: urls, streamName: streamName))
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
            
            var selectedVariant : [String: Any]? = nil
            for stream in self.provisionList! {
                let s = stream as! [String:Any]
                if s["name"] as! String == streamName {
                    selectedVariant = s
                    break
                }
            }
            
            //   Create a new connection using the configuration above
            let connection = R5Connection(config: config)
            let type = self.getPublishRecordType ()
            
            //   UI updates must be asynchronous
            DispatchQueue.main.async(execute: {
                
                for uibutton in self.view.subviews {
                    if let btn = uibutton as? UIButton {
                        btn.removeFromSuperview()
                    }
                }
                
                self.setupDefaultR5VideoViewController()
                //   Create our new stream that will utilize that connection
                self.setupPublisherWithVariant(connection: connection!, variant: selectedVariant!)
                // show preview and debug info
                
                self.currentView!.attach(self.publishStream!)
                
                self.publishStream!.publish(streamName, type: type)
                
                let label = UILabel(frame: CGRect(x: 0, y: self.view.frame.height-24, width: self.view.frame.width, height: 24))
                label.textAlignment = NSTextAlignment.left
                label.backgroundColor = UIColor.lightGray
                label.text = "Connected to: " + ip!
                self.view.addSubview(label)
            })

        }
        
    }
    
    func sendProvisions (name: String, data: [String : Any]) {
        
        let port = (Testbed.getParameter(param: "server_port") as! String)
        let portURI = (port == "80" || port == "443") ? "" : ":" + port
        let version = (Testbed.getParameter(param: "sm_version") as! String)
        let accessToken = (Testbed.getParameter(param: "sm_access_token") as! String)
        let originURI = (Testbed.getParameter(param: "host") as! String) + portURI + "/streammanager/api/" + version +
            "/admin/event/meta/" +
            (Testbed.getParameter(param: "context") as! String) + "/" +
            name + "?accessToken=" + accessToken
        
        let httpString = "http://" + originURI
        let httpsString = "https://" + originURI
        
        var urls = [httpString, httpsString]
        
        postProvisions(urls.popLast()!, data: data, resolve: respondToProvisions(data: data, urls: urls))

    }
    
    func getOrigin (name: String, topLevelStreamName: String) {
        let port = (Testbed.getParameter(param: "server_port") as! String)
        let portURI = (port == "80" || port == "443") ? "" : ":" + port
        let version = (Testbed.getParameter(param: "sm_version") as! String)
        let originURI = (Testbed.getParameter(param: "host") as! String) + portURI + "/streammanager/api/" + version +
            "/event/" +
            (Testbed.getParameter(param: "context") as! String) + "/" +
            name + "?action=broadcast&transcode=true"
        
        let httpString = "http://" + originURI
        let httpsString = "https://" + originURI
        
        var urls = [httpString, httpsString]
        
        requestOrigin(urls.popLast()!, resolve: respondToOrigin(urls: urls, streamName: topLevelStreamName))
    }
    
    @objc func selectStream(sender: UITapGestureRecognizer) {
        
        let streamName = (Testbed.getParameter(param: "stream1") as? String)
        let button = sender.view as? UIButton
        let name = button?.title(for: UIControl.State.normal) ?? streamName! + "_1"
        
        self.getOrigin(name: streamName!, topLevelStreamName: name)
        
        for uibutton in self.view.subviews {
            if let btn = uibutton as? UIButton {
                btn.isEnabled = false
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in };
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = (storyboard.instantiateViewController(withIdentifier: "PublishTranscoderForm") as? PublishTranscoderForm)!
        vc.delegate = self
        vc.view.backgroundColor = UIColor.white
        self.addChild(vc)
        self.view.addSubview(vc.view)
        vc.view.frame = CGRect(x:0, y:0, width:self.view.frame.width, height: self.view.frame.height)
        vc.view.layoutSubviews()

    }
    
    func onProvisionSubmit (_ controller: PublishTranscoderForm) {
        controller.view.removeFromSuperview()
        controller.removeFromParent()
        
        let high = controller.getHighFormValues()
        let medium = controller.getMediumFormValues()
        let low = controller.getLowFormValues()
        
        let name = (Testbed.getParameter(param: "stream1") as! String)
        var level = 3
        let provisions = [low, medium, high].map {
            (values: (Int, Int, Int)) -> [String:Any] in
            let variant: [String : Any] = [
                "name": name + "_" + String(level),
                "level": level,
                "properties": [
                    "videoBR": values.0,
                    "videoWidth": values.1,
                    "videoHeight": values.2
                ]
            ]
            level = level - 1
            return variant
        }
        let transcoderPOST : [String : Any ] = [
          "meta": [
            "authentication": [
              "username": "",
              "password": ""
            ],
            "stream": provisions,
            "georules": [
              "regions": ["US", "UK"],
              "restricted": false
            ],
            "qos": 3
          ]
        ]
        
        self.sendProvisions(name: name, data: transcoderPOST)
    }
    
}
