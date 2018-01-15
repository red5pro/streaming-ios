//
//  PublishStreamManagerTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 4/8/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(PublishStreamManagerTest)
class PublishStreamManagerTest: BaseTest {
    
    func showInfo(title: String, message: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                // Trying to redirect user to details form...
//              controller?.performSegue(withIdentifier: "showDetail", sender: test)
            }))
            self.present(alert, animated: true, completion: nil)
        })
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
                    self.requestOrigin(urls.popLast()!, resolve: self.responder(urls: urls))
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
                //   Create our new stream that will utilize that connection
                self.setupPublisher(connection: connection!)
                // show preview and debug info
                
                self.currentView!.attach(self.publishStream!)
                
                self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: R5RecordTypeLive)
                
                let label = UILabel(frame: CGRect(x: 0, y: self.view.frame.height-24, width: self.view.frame.width, height: 24))
                label.textAlignment = NSTextAlignment.left
                label.backgroundColor = UIColor.lightGray
                label.text = "Connected to: " + ip!
                self.view.addSubview(label)
            })

        }
    }

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in };
        
        setupDefaultR5VideoViewController()
        
        let port = (Testbed.getParameter(param: "server_port") as! String)
        let portURI = port == "80" ? "" : ":" + port
        let originURI = (Testbed.getParameter(param: "host") as! String) + portURI + "/streammanager/api/2.0/event/" +
            (Testbed.getParameter(param: "context") as! String) + "/" +
            (Testbed.getParameter(param: "stream1") as! String) + "?action=broadcast"
        let httpString = "http://" + originURI
        let httpsString = "https://" + originURI
        
        var urls = [httpString, httpsString]
        
        requestOrigin(urls.popLast()!, resolve: responder(urls: urls))
    }
    
}
