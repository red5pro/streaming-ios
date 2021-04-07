//
//  SharedObjectTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 1/26/17.
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

@objc(SharedObjectTest)
class SharedObjectTest: BaseTest, UITextViewDelegate {
    
    var sObject : R5SharedObject? = nil
    var chatView: UITextView? = nil
    var chatInput: UITextView? = nil
    var sendBtn: UIButton? = nil
    var messageBuffer: NSMutableArray = []
    var timer: Timer? = nil
    var thisUser: String = "subscriber"
    var SOConnected : Bool = false
    
    func getTextColorGestureRecognizer () -> UIGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(setTextColor))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in
        
        };
        
        setupDefaultR5VideoViewController()
        
        let tapOut = UITapGestureRecognizer(target: self, action: #selector(textViewDidEndEditing))
        view.addGestureRecognizer(tapOut)
        
        let screenSize = UIScreen.main.bounds.size
        
        //make textviews
        chatView = UITextView(frame: CGRect(x: 0, y: screenSize.height * 0.5, width: screenSize.width * 0.6, height: (screenSize.height * 0.5) - 60))
        chatView?.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        chatView?.isEditable = false
        view.addSubview(chatView!)
        addMessage(message: "Waiting for Stream Connection")
        
        let redButton = UIButton(frame: CGRect(x: 2, y: screenSize.height - 58, width: 32, height: 32))
        redButton.backgroundColor = UIColor.red;
        redButton.setTitleColor(UIColor.red, for: UIControl.State.normal);
        redButton.setTitle("#ff0000", for: UIControl.State.normal)
        view.addSubview(redButton)
        redButton.addGestureRecognizer(getTextColorGestureRecognizer())
        
        let greenButton = UIButton(frame: CGRect(x: 36, y: screenSize.height - 58, width: 32, height: 32))
        greenButton.backgroundColor = UIColor.green;
        greenButton.setTitleColor(UIColor.green, for: UIControl.State.normal);
        greenButton.setTitle("#00ff00", for: UIControl.State.normal)
        view.addSubview(greenButton)
        greenButton.addGestureRecognizer(getTextColorGestureRecognizer())
        
        let blueButton = UIButton(frame: CGRect(x: 70, y: screenSize.height - 58, width: 32, height: 32))
        blueButton.backgroundColor = UIColor.blue;
        blueButton.setTitleColor(UIColor.blue, for: UIControl.State.normal);
        blueButton.setTitle("#0000ff", for: UIControl.State.normal)
        view.addSubview(blueButton)
        blueButton.addGestureRecognizer(getTextColorGestureRecognizer())
        
        let blackButton = UIButton(frame: CGRect(x: 104, y: screenSize.height - 58, width: 32, height: 32))
        blackButton.backgroundColor = UIColor.black;
        blackButton.setTitleColor(UIColor.black, for: UIControl.State.normal);
        blackButton.setTitle("#000000", for: UIControl.State.normal)
        view.addSubview(blackButton)
        blackButton.addGestureRecognizer(getTextColorGestureRecognizer())
        
        chatInput = UITextView(frame: CGRect(x: 0, y: screenSize.height - 24, width: (screenSize.width * 0.6) - 50, height: 24) )
        chatInput?.backgroundColor = UIColor.lightGray
        chatInput?.isEditable = true
        chatInput?.delegate = self
        view.addSubview(chatInput!)
        
        sendBtn = UIButton(frame: CGRect(x: (screenSize.width * 0.6) - 50, y: screenSize.height - 24, width: 50, height: 24))
        sendBtn?.backgroundColor = UIColor.darkGray
        sendBtn?.setTitle("Send", for: UIControl.State.normal)
        view.addSubview(sendBtn!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(sendMessage))
        sendBtn?.addGestureRecognizer(tap)
        
        callForStreamList();
    }
    
    @objc func callForStreamList(){
        
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
                        self.setupPublisher(connection: connection!)
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
        else if(Int(statusCode) == Int(r5_status_disconnected.rawValue)
            || Int(statusCode) == Int(r5_status_connection_close.rawValue)){
            SOConnected = false
        }
    }
    
    @objc func SOConnect(){
        let stream = (publishStream != nil) ? publishStream : subscribeStream;
        NSLog("%@", "Sending shared object connection request")
        
        sObject = R5SharedObject(name:"sharedChatTest", connection: stream?.connection);
        sObject?.client = self;
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    //callback for remote object connection - remote object now available
    @objc func onSharedObjectConnect( objectValue: NSDictionary){
        SOConnected = true;
        let data : NSMutableDictionary = (sObject?.data)!
        if let c = data["color"] {
            setChatViewToHex(hexString: c as! String)
        }
    }

    @objc func sendMessage(){
        
        textViewDidEndEditing(chatInput!)
        
        if( (chatInput?.text.isEmpty)! ){
            return
        }
        
        let messageOut : [AnyHashable:Any] = [ "user":thisUser, "message":(chatInput?.text)! ]
        
        //Calls for the relevant method with the sent parameters on all clients listening to the shared object
        //Note - This includes the client that sends the call
        sObject?.send("messageTransmit", withParams: messageOut)
        
        chatInput?.text = ""
    }
    
    @objc func setChatViewToHex (hexString: String) {
        let hex = hexString.replacingOccurrences(of: "#", with: "")
        var rgb: UInt32 = 0
        guard Scanner(string: hex).scanHexInt32(&rgb) else { return }
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        let color = UIColor(red:r, green:g, blue:b, alpha: CGFloat(1.0))
        chatView?.textColor = color;
    }
    
    @objc func setTextColor (recognizer: UITapGestureRecognizer) {
        let button : UIButton = recognizer.view as! UIButton
        let hex = button.title(for: UIControl.State.normal)
        sObject?.setProperty("color", withValue: hex as NSObject?)
        setChatViewToHex(hexString: hex!)
//        let messageOut : [AnyHashable:Any] = [ "user":thisUser, "message":"Color changed to: " + hex! ]
//        sObject?.send("messageTransmit", withParams: messageOut)
    }
    
    //Called whenever a property of the shared object is changed
    @objc func onUpdateProperty( propertyInfo: [AnyHashable: Any] ) {
//        propertyInfo.keys[0] can be used to find which property has updated.
        if let c = propertyInfo["color"] {
            setChatViewToHex(hexString: c as! String)
        }
    }
    
    @objc func messageTransmit( messageIn: [AnyHashable: Any] ){
        
        let user: String = messageIn["user"] as! String
        let message : String = messageIn["message"] as! String
        
        let display: String = "User \"" + user + "\": " + message
        
        addMessage(message: display)
    }
    
    override func closeTest() {
        
        if( self.timer != nil ){
            self.timer?.invalidate();
        }
        
        if(SOConnected){
            sObject?.close()
        }
        
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
        
        chatInput?.frame = CGRect(x:0, y:screenSize.height * 0.5, width: (screenSize.width * 0.6) - 50, height: 24)
        sendBtn?.frame = CGRect(x: (screenSize.width * 0.6) - 50, y: screenSize.height * 0.5, width: 50, height: 24)
    }
    
    @objc func textViewDidEndEditing(_ textView: UITextView) {
        
        view.endEditing(true)
        
        let screenSize = UIScreen.main.bounds.size
        
        chatInput?.frame = CGRect(x:0, y: screenSize.height - 24, width: (screenSize.width * 0.6) - 50, height: 24)
        sendBtn?.frame = CGRect(x: (screenSize.width * 0.6) - 50, y: screenSize.height - 24, width: 50, height: 24)
        
        chatInput?.resignFirstResponder()
    }
}
