//
//  SharedObjectTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 1/26/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SharedObjectTest)
class SharedObjectTest: BaseTest, UITextViewDelegate {
    
    var sObject : R5SharedObject? = nil
    var chatView: UITextView? = nil
    var chatInuput: UITextView? = nil
    var sendBtn: UIButton? = nil
    var messageBuffer: NSMutableArray = []
    var timer: Timer? = nil
    var thisUser: Int = -1
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in
        
        };
        
        setupDefaultR5VideoViewController()
        
        let tapOut = UITapGestureRecognizer(target: self, action: #selector(textViewDidEndEditing))
        view.addGestureRecognizer(tapOut)
        
        let screenSize = UIScreen.main.bounds.size
        
        //make textviews
        chatView = UITextView(frame: CGRect(x: 0, y: screenSize.height * 0.5, width: screenSize.width * 0.6, height: (screenSize.height * 0.5) - 24))
        chatView?.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        chatView?.isEditable = false
        view.addSubview(chatView!)
        addMessage(message: "Waiting for Stream Connection")
        
        chatInuput = UITextView(frame: CGRect(x: 0, y: screenSize.height - 24, width: (screenSize.width * 0.6) - 50, height: 24) )
        chatInuput?.backgroundColor = UIColor.lightGray
        chatInuput?.isEditable = true
        chatInuput?.delegate = self
        view.addSubview(chatInuput!)
        
        sendBtn = UIButton(frame: CGRect(x: (screenSize.width * 0.6) - 50, y: screenSize.height - 24, width: 50, height: 24))
        sendBtn?.backgroundColor = UIColor.darkGray
        sendBtn?.setTitle("Send", for: UIControlState.normal)
        view.addSubview(sendBtn!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(sendMessage))
        sendBtn?.addGestureRecognizer(tap)
        
        callForStreamList();
    }
    
    func callForStreamList(){
        
        let domain = Testbed.getParameter(param: "host") as! String
        let app = Testbed.getParameter(param: "context") as! String
        let url = "http://" + domain + ":5080/" + app + "/streams.jsp"
        let request = URLRequest.init(url: URL.init(string: url)!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.init(), completionHandler: { (response: URLResponse?, data: Data?, error: Error?) -> Void in
            self.streamListReturn(response: response, data: data, error: error)
        })
    }
    
    func delayCallForList() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(callForStreamList), userInfo: nil, repeats: false)
    }
    
    //add to destroy - close the web call and timer if it's running
    
    func streamListReturn( response: URLResponse?, data: Data?, error: Error? ){
    
        addMessage(message: "Retrieved List")
        // Set up the configuration
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        
        //parse the response
        if (error != nil) {
            NSLog("Error, %@", error!.localizedDescription);
            delayCallForList();
        } else {
            
            do{
                let list = try JSONSerialization.jsonObject(with: data!) as! Array<Dictionary<String, String>>;
                
                var shouldPublish: Bool = true;
                for dict:Dictionary<String, String> in list {
                    if(dict["name"] == (Testbed.getParameter(param: "stream1") as! String)){
                        shouldPublish = false;
                        break;
                    }
                }
                
                DispatchQueue.main.async {
                    
                    if(shouldPublish){
                        self.setupPublisher(connection!)
                        self.currentView!.attach(self.publishStream!)
                        self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: R5RecordTypeLive)
                        self.addMessage(message: "Begining Publish")
                    }
                    else{
                        self.subscribeStream = R5Stream(connection: connection)
                        self.subscribeStream!.delegate = self
                        self.subscribeStream?.client = self;
                        
                        self.currentView?.attach(self.subscribeStream)
                        
                        self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String)
                        self.addMessage(message: "Begin Subscribe")
                    }
                }
                
            }catch let error as NSError {
                print(error)
                delayCallForList();
            }
        }
        
    }
    
    override func onR5StreamStatus( _ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        super.onR5StreamStatus(stream, withStatus: statusCode, withMessage: msg)
        
        if(Int(statusCode) == Int(r5_status_start_streaming.rawValue)){
            
            self.timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(SOConnect), userInfo: nil, repeats: false)
        }
    }
    
    func SOConnect(){
        let stream = (publishStream != nil) ? publishStream : subscribeStream;
        NSLog("%@", "Sending shared object connection request")
        
        sObject = R5SharedObject(name:"sharedChatTest", connection: stream?.connection);
        sObject?.client = self;
    }
    
    //callback for remote object connection - remote object now available
    func onSharedObjectConnect( objectValue: NSDictionary){
        addMessage(message: "Connected to object, there are " + ((objectValue["count"] != nil) ? String(describing: objectValue["count"]) : "no") + " other people connected");
        thisUser = (objectValue["count"] != nil) ? (objectValue["count"] as! Int) + 1 : 1;
        //set the count property to add yourself
        sObject?.setProperty("count", withValue: (objectValue["count"] != nil ? (objectValue["count"] as! Int) + 1 : 1) as NSNumber)
    }

    func sendMessage(){
        
        textViewDidEndEditing(chatInuput!)
        
        if( (chatInuput?.text.isEmpty)! ){
            return
        }
        
        let messageOut : [AnyHashable:Any] = [ "user":String(thisUser), "message":(chatInuput?.text)! ]
        
        //Calls for the relevant method with the sent parameters on all clients listening to the shared object
        //Note - This includes the client that sends the call
        sObject?.send("messageTransmit", withParams: messageOut)
        
        chatInuput?.text = ""
    }
    
    //Called whenever a property of the shared object is changed
    func onUpdateProperty( propertyInfo: [AnyHashable: Any] ) {
//        propertyInfo.keys[0] can be used to find which property has updated.
        addMessage(message: "Room update - There are now " + String(describing: propertyInfo["count"]) + " users")
    }
    
    func messageTransmit( messageIn: [AnyHashable: Any] ){
        
        let user: String = messageIn["user"] as! String
        let message : String = messageIn["message"] as! String
        
        var display: String = ""
        
        if(user != (Testbed.getParameter(param: "stream1") as! String)){
            
            display = "user#" + user + ": " + message
        }
        
        addMessage(message: display)
    }
    
    override func closeTest() {
        
        if( self.timer != nil ){
            self.timer?.invalidate();
        }
        
        sObject?.setProperty("count", withValue:((sObject?.data["count"] as! Int) - 1) as NSNumber )
        sObject?.close()
        
        super.closeTest()
    }
    
    func addMessage( message: String, update: Bool = true ){
        
        DispatchQueue.main.async {
            
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "hh:mm:ss.SSS"
            let dateString = dateFormat.string(from: NSDate() as Date)
            
            self.messageBuffer.add(dateString + " " + message)
            
            if( update ){
                self.chatUpdate();
            }
        }
    }
    
    func chatUpdate() {
        while messageBuffer.count > 20 {
            messageBuffer.removeObject(at: 0)
        }
        
        var textOut: String = ""
        
        for line in messageBuffer {
            textOut += (line as! String) + "\n"
        }
        
        chatView?.text = textOut
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let screenSize = UIScreen.main.bounds.size
        
        chatInuput?.frame = CGRect(x:0, y:screenSize.height * 0.5, width: (screenSize.width * 0.6) - 50, height: 24)
        sendBtn?.frame = CGRect(x: (screenSize.width * 0.6) - 50, y: screenSize.height * 0.5, width: 50, height: 24)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        view.endEditing(true)
        
        let screenSize = UIScreen.main.bounds.size
        
        chatInuput?.frame = CGRect(x:0, y: screenSize.height - 24, width: (screenSize.width * 0.6) - 50, height: 24)
        sendBtn?.frame = CGRect(x: (screenSize.width * 0.6) - 50, y: screenSize.height - 24, width: 50, height: 24)
        
        chatInuput?.resignFirstResponder()
    }
}
