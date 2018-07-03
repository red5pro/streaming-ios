//
//  TwoWayStreamManagerTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 7/2/18.
//  Copyright © 2018 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(TwoWayStreamManagerTest)
class TwoWayStreamManagerTest: BaseTest {
    var publishView : R5VideoViewController? = nil
    var timer : Timer? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestServer("broadcast") { (url) in
            publishTo(url: url)
        }
        callForStreamList()
    }
    
    func requestServer(_ action: String, resolve: @escaping (_ ip: String) -> Void) {
        
        let port = (Testbed.getParameter(param: "server_port") as! String)
        let portURI = port == "80" ? "" : ":" + port
        let originURI = "http://" + (Testbed.getParameter(param: "host") as! String) + portURI + "/streammanager/api/2.0/event/" +
            (Testbed.getParameter(param: "context") as! String) + "/" +
            (Testbed.getParameter(param: "stream1") as! String) + "?action=" + action
        
        NSURLConnection.sendAsynchronousRequest(
            NSURLRequest( url: NSURL(string: originURI)! as URL ) as URLRequest,
            queue: OperationQueue(),
            completionHandler:{ (response: URLResponse?, data: Data?, error: Error?) -> Void in
                
                if ((error) != nil) {
                    print(error)
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
                    resolve(ip)
                }
                else if let errorMessage = json["errorMessage"] as? String {
                    print(AccessError.error(message: errorMessage))
                }
                
        })
    }
    
    func delayCallForList() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(callForStreamList), userInfo: nil, repeats: false)
    }
    
    func callForStreamList(){
        
        let domain = Testbed.getParameter(param: "host") as! String
        let url = "http://" + domain + ":5080/streammanager/api/2.0/event/list"
        let request = URLRequest.init(url: URL.init(string: url)!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.init(), completionHandler: { (response: URLResponse?, data: Data?, error: Error?) -> Void in
            
            //parse the response
            if (error != nil) {
                NSLog("Error, %@", error!.localizedDescription)
            } else {
                
                do{
                    let list = try JSONSerialization.jsonObject(with: data!) as! Array<Dictionary<String, String>>;
                    
                    for dict:Dictionary<String, String> in list {
                        if(dict["name"] == (Testbed.getParameter(param: "stream2") as! String)){
                            requestServer("subscribe", resolve: { (url) in
                                subscribeTo(url: url)
                            })
                            return
                        }
                    }
                    
                    
                }catch let error as NSError {
                    print(error)
                }
            }
            
            delayCallForList()
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
            
            // show preview and debug info
            self.publishView!.attach(self.publishStream!)
            
            self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: R5RecordTypeLive)
            
            let label = UILabel(frame: CGRect(x: 0, y: self.view.frame.height-24, width: self.view.frame.width, height: 24))
            label.textAlignment = NSTextAlignment.left
            label.backgroundColor = UIColor.lightGray
            label.text = "Pub Connected to: " + ip!
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
            let connection = R5Connection(config: config)
            self.subscribeStream = R5Stream(connection: connection)
            
            // show preview and debug info
            currentView?.attach(subscribeStream)
            
            self.subscribeStream!.play(Testbed.getParameter(param: "stream2") as! String)
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 24))
            label.textAlignment = NSTextAlignment.left
            label.backgroundColor = UIColor.lightGray
            label.text = "Sub Connected to: " + ip!
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
