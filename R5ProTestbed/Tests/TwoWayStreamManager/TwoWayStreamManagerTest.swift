//
//  TwoWayStreamManagerTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 7/2/18.
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

@objc(TwoWayStreamManagerTest)
class TwoWayStreamManagerTest: BaseTest {
    var publishView : R5VideoViewController? = nil
    var timer : Timer? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupDefaultR5VideoViewController()
        
        requestServer(Testbed.getParameter(param: "stream1") as! String, action: "broadcast", resolve: { (url) in
            self.publishTo(url: url)
        })
        callForStreamList()
    }
    
    func requestServer(_ streamName: String, action: String, resolve: @escaping (_ ip: String) -> Void) {
        
        print("Requesting for stream: " + streamName + " - and action= " + action)
        
        let port = (Testbed.getParameter(param: "server_port") as! String)
        let portURI = port == "80" || port == "443" ? "" : ":" + port
        let version = (Testbed.getParameter(param: "sm_version") as! String)
        let originURI = (Testbed.getParameter(param: "host") as! String) + portURI + "/streammanager/api/" + version + "/event/" +
            (Testbed.getParameter(param: "context") as! String) + "/" + streamName + "?action=" + action
        
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
                }catch{
                    print(error)
                    return
                }
                
                if let ip = json["serverAddress"] as? String {
                    resolve(ip)
                }
                else if let errorMessage = json["errorMessage"] as? String {
                    print(AccessError.error(message: errorMessage))
                    if(action == "subscribe"){
                        self.delayCallForList()
                    }
                }
                
        })
    }
    
    func delayCallForList() {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.callForStreamList), userInfo: nil, repeats: false)
        }
    }
    
    @objc func callForStreamList(){
        
//        let domain = Testbed.getParameter(param: "host") as! String
//        let url = "http://" + domain + ":5080/streammanager/api/2.0/event/list"
        let port = (Testbed.getParameter(param: "server_port") as! String)
        let portURI = port == "80" || port == "443" ? "" : ":" + port
        let version = (Testbed.getParameter(param: "sm_version") as! String)
        let originURI = (Testbed.getParameter(param: "host") as! String) + portURI + "/streammanager/api/" + version + "/event/list"
        let url = (portURI.isEmpty ? "https://" : "http://") + originURI
        
        let request = URLRequest.init(url: URL.init(string: url)!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.init(), completionHandler: { (response: URLResponse?, data: Data?, error: Error?) -> Void in
            
            //parse the response
            if (error != nil) {
                NSLog("Error, %@", error!.localizedDescription)
            } else {
//                print("Recieved list: " + String(data: data!, encoding: String.Encoding.utf8)!)
                do{
                    let list = try JSONSerialization.jsonObject(with: data!) as! Array<[String: Any]>
                        
                    for dict:[String: Any] in list {
                        if((dict["name"] as! String) == (Testbed.getParameter(param: "stream2") as! String)){
                            self.requestServer(Testbed.getParameter(param: "stream2") as! String, action: "subscribe", resolve: { (url) in
                                self.subscribeTo(url: url)
                            })
                            return
                        }
                    }
                    
                    
                }catch let error as NSError {
                    print(error)
                }
            }
            
            self.delayCallForList()
        })
    }
    
    func publishTo( url: String ){
        let config = getConfig()
        config.host = url
        
        //   Create a new connection using the configuration above
        let connection = R5Connection(config: config)
        
        //   UI updates must be on the main queue
        DispatchQueue.main.async(execute: {
            //   Create our new stream that will utilize that connection
            self.setupPublisher(connection: connection!)
            
            self.publishView = self.getNewR5VideoViewController(rect: self.view.frame);
            self.addChild(self.publishView!);
            
            self.view.addSubview(self.publishView!.view)
            
            self.publishView!.showPreview(true)
            
            self.publishView!.showDebugInfo(Testbed.getParameter(param: "debug_view") as! Bool)
            
            // show preview and debug info
            self.publishView!.attach(self.publishStream!)
            
            let screenSize = UIScreen.main.bounds.size
            let newFrame = CGRect(x: screenSize.width * (3/5), y: screenSize.height * (3/5), width: screenSize.width * (2/5), height: screenSize.height * (2/5) )
            self.publishView?.view.frame = newFrame
            
            self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: R5RecordTypeLive)
            
            let label = UILabel(frame: CGRect(x: 0, y: self.view.frame.height-24, width: self.view.frame.width, height: 24))
            label.textAlignment = NSTextAlignment.left
            label.backgroundColor = UIColor.lightGray
            label.text = "Pub Connected to: " + url
            self.view.addSubview(label)
        })
    }
    
    func subscribeTo( url: String ) {
        let config = getConfig()
        config.host = url
        
        //   Create a new connection using the configuration above
        let connection = R5Connection(config: config)
        
        //   UI updates must be on the main queue
        DispatchQueue.main.async(execute: {
            //   Create our new stream that will utilize that connection
            self.subscribeStream = R5Stream(connection: connection)
            
            // show preview and debug info
            self.currentView?.attach(self.subscribeStream!)
            
            self.subscribeStream!.play(Testbed.getParameter(param: "stream2") as! String, withHardwareAcceleration:Testbed.getParameter(param: "hwaccel_on") as! Bool)
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 24))
            label.textAlignment = NSTextAlignment.left
            label.backgroundColor = UIColor.lightGray
            label.text = "Sub Connected to: " + url
            self.view.addSubview(label)
        })
    }
    
    override func closeTest() {
        
        if( self.timer != nil ){
            self.timer!.invalidate();
        }
        
        super.closeTest()
    }
}
