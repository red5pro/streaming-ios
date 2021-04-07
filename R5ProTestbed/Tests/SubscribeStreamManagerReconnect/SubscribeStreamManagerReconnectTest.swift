//
//  SubscribeStreamManagerReconnectTest.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 01/21/2021.
//  Copyright © 2018 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeStreamManagerReconnectTest)
class SubscribeStreamManagerReconnectTest: BaseTest {
    
    var closing : Bool = false
    var alert : UIAlertController?
    var infoLabel : UILabel?
    var delayIsActive : Bool = false
    
    override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        
        super.onR5StreamStatus(stream, withStatus: statusCode, withMessage: msg)
        
        if (stream == self.subscribeStream) {
            
            if(statusCode == Int32(r5_status_connection_error.rawValue)){
                
                //we can assume it failed here!
                NSLog("Connection error")
                self.stopSubscription()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    guard let self = self else { return }
                    self.showInfo(title: "Error", message: msg)
                    self.delayCallForList()
                }
                
            }
            else if (statusCode == Int32(r5_status_netstatus.rawValue) && msg == "NetStream.Play.UnpublishNotify") {
                
                
                self.stopSubscription()
                // publisher stopped broadcast. let's resume autoconnect logic.
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    guard let self = self else { return }
                    self.showInfo(title: "Info", message: "Broadcast Unpublished")
                    self.delayCallForList()
                }
            }
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        setupDefaultR5VideoViewController()
        
        if (self.infoLabel == nil) {
            self.infoLabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.height-24, width: self.view.frame.width, height: 24))
            self.infoLabel?.textAlignment = NSTextAlignment.left
            self.infoLabel?.backgroundColor = UIColor.lightGray
            self.view.addSubview(self.infoLabel!)
        }
        
        callForStreamList()
        
    }
    
    func requestServer(_ streamName: String, action: String, resolve: @escaping (_ ip: String) -> Void) {
        
        if (self.closing) {
            return
        }
        
        let domain = Testbed.getParameter(param: "host") as! String
        let port = (Testbed.getParameter(param: "server_port") as! String)
        let portURI = port == "80" ? "" : ":" + port
        let version = (Testbed.getParameter(param: "sm_version") as! String)
        let url = "https://" + domain + portURI + "/streammanager/api/" + version + "/event/" +
            (Testbed.getParameter(param: "context") as! String) + "/" + streamName + "?action=" + action
        
        var request = URLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                
                if ((error) != nil) {
                    print(error!)
                    self.showInfo(title: "Error", message: error!.localizedDescription)
                    self.stopSubscription()
                }
                
                //   The string above is in JSON format, we specifically need the serverAddress value
                var json: [String: AnyObject]
                do{
                    json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [String: AnyObject]
                    
                    if let ip = json["serverAddress"] as? String {
                        resolve(ip)
                        return
                    } else if let errorMessage = json["errorMessage"] as? String {
                        print(AccessError.error(message: errorMessage))
                        self.showInfo(title: "Error", message: errorMessage)
                        self.stopSubscription()
                    }
                    
                }catch{
                    print(error)
                    self.showInfo(title: "Error:", message: error.localizedDescription)
                    self.stopSubscription()
                }
                
                self.delayIsActive = false
                self.delayCallForList()
                
        })
        
        task.resume()
    }
    
    func updateInfo (msg : String) {
        DispatchQueue.main.async(execute: { [weak self] in
            guard let self = self else { return }
            self.infoLabel?.text = msg
        })
    }
   
    func showInfo(title: String, message: String){
        DispatchQueue.main.async(execute: { [weak self] in
            guard let self = self else { return }
            if (self.alert != nil) {
                self.dismiss(animated: true, completion: {
                    self.alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
                    self.alert?.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                        // Trying to redirect user to details form...
                        //            controller?.performSegue(withIdentifier: "showDetail", sender: test)
                    }))
                    self.present(self.alert!, animated: true, completion: nil)
                })
            } else {
                self.alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
                self.alert?.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                    // Trying to redirect user to details form...
                    //            controller?.performSegue(withIdentifier: "showDetail", sender: test)
                }))
                self.present(self.alert!, animated: true, completion: nil)
            }
        })
    }
    
    func delayCallForList() {
        
        if (self.delayIsActive) {
            return
        }
        self.delayIsActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
//            self.showInfo(title: "Info", message: "Requesting stream list...")
            self.updateInfo(msg: "Requesting stream list...")
            self.callForStreamList()
        }
        
    }
    
    @objc func callForStreamList() {
        
        if (self.closing) {
            return
        }
        
        let domain = Testbed.getParameter(param: "host") as! String
        let port = (Testbed.getParameter(param: "server_port") as! String)
        let portURI = port == "80" ? "" : ":" + port
        let version = (Testbed.getParameter(param: "sm_version") as! String)
        let url = "https://" + domain + portURI + "/streammanager/api/" + version + "/event/list"
        
        var request = URLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in

            //parse the response
            if (error != nil) {
                NSLog("Error, %@", error!.localizedDescription)
                self.showInfo(title: "Error", message: error!.localizedDescription)
            } else {
                
                do{
                    let list = try JSONSerialization.jsonObject(with: data!) as! Array<Dictionary<String, Any>>;
                    
                    for dict:Dictionary<String, Any> in list {
                        let isStream = dict["name"] as! String == (Testbed.getParameter(param: "stream1") as! String)
                        let isEdge = dict["type"] as! String == "edge"
                        if (isStream && isEdge) {
                            self.requestServer(Testbed.getParameter(param: "stream1") as! String, action: "subscribe", resolve: { (url) in
                                self.subscribeTo(url: url)
                            })
                            return
                        }
                    }
                    
                    
                } catch let error as NSError {
                    self.showInfo(title: "Error", message: error.localizedDescription)
                    print(error)
                }
            }
            
            self.updateInfo(msg: "Stream Does Not Exist")
            self.delayIsActive = false
            self.delayCallForList()
        })
        
        task.resume()
    }
  
    func subscribeTo( url: String ) {
        
        let config = getConfig()
        config.host = url
        // For client testing...
        config.parameters = "username=demoAppUsername;password=demoAppPassword;token=demoAppToken;"
        
        //   Create a new connection using the configuration above
        let connection = R5Connection(config: config)
        
        self.stopSubscription()
        
        //   UI updates must be on the main queue
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            
            guard let self = self else { return }
            
            ALToastView.toast(in: self.view, withText:"Requesting to subscribe...")
            
            if (self.alert != nil) {
                self.dismiss(animated: true, completion: nil)
                self.alert = nil
            }
            self.delayIsActive = false
            //   Create our new stream that will utilize that connection
            self.subscribeStream = R5Stream(connection: connection)
            self.subscribeStream?.audioController = R5AudioController()
            self.subscribeStream?.delegate = self
            
            // show preview and debug info
            self.currentView?.attach(self.subscribeStream!)
            
            self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String, withHardwareAcceleration:Testbed.getParameter(param: "hwaccel_on") as! Bool)
            
            self.updateInfo(msg: "Sub Connected to: " + url)
            
        }
    }
    
    func stopSubscription () {
        if(self.subscribeStream != nil) {
            DispatchQueue.main.async(execute: { [subscribeStream, self] in
                
                guard let subscribeStream = subscribeStream else { return }
            
                self.currentView?.attach(nil)
                subscribeStream.delegate = nil
                subscribeStream.stop()
                self.subscribeStream = nil
            })
        }
    }
    
    override func closeTest() {
        
        self.closing = true
        super.closeTest()
        
        self.stopSubscription()
        if (self.currentView != nil) {
            self.currentView?.attach(nil)
            self.currentView?.view.removeFromSuperview()
            self.currentView?.removeFromParent()
            self.currentView?.viewDidDisappear(false)
        }
        self.cleanup()
    }
}
