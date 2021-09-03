//
//  SharedObjectStreamlessTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 8/19/19.
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

@objc(SharedObjectStreamlessTest)
class SharedObjectStreamlessTest: SharedObjectTest, R5ConnectionDelegate {
    
    var connection : R5Connection? = nil
    
    var roomInput: UITextView? = nil
    var connectBtn: UIButton? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        var screenSize = self.view.bounds.size
        if #available(iOS 11.0, *) {
            screenSize =  self.view.safeAreaLayoutGuide.layoutFrame.size
        }
        chatView?.frame = CGRect(x: 0, y: screenSize.height * 0.25, width: screenSize.width, height: (screenSize.height * 0.75) - 24);
        
        roomInput = UITextView(frame: CGRect(x: 0, y: 0, width: (screenSize.width * 0.6) - 50, height: 32) )
        roomInput?.backgroundColor = UIColor.lightGray
        roomInput?.isEditable = true
        roomInput?.delegate = self
        roomInput?.text = "sharedChatTest";
        view.addSubview(roomInput!)
        
        connectBtn = UIButton(frame: CGRect(x: (screenSize.width * 0.6) - 50, y: 0, width: screenSize.width - ((screenSize.width * 0.6) - 50), height: 32))
        connectBtn?.backgroundColor = UIColor.darkGray
        connectBtn?.setTitle("Connect To SO", for: UIControl.State.normal)
        connectBtn?.isEnabled = false
        view.addSubview(connectBtn!)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(roomConnectDisconnect))
        connectBtn?.addGestureRecognizer(tap)
        
        startConnection()
        
        sendBtn?.isEnabled = false
    }
    
    func startConnection() {
        // Set up the configuration
        let config = getConfig()
        // Set up the connection and stream
        connection = R5Connection(config: config)
        connection?.delegate = self
        connection?.client = self
        
        connection?.startDataOnlyStream()
    }
    
    @objc override func callForStreamList(){
        // Overridden to stop from calling for the list and publishing/subscribing
        // intentionally left empty
    }
    
    func onR5ConnectionStatus(_ connection: R5Connection!, withStatus statusCode: Int32, withMessage msg: String!) {
        
        if(Int(statusCode) == Int(r5_status_start_streaming.rawValue)){
            connectBtn?.isEnabled = true
        }
        else if(Int(statusCode) == Int(r5_status_disconnected.rawValue)
            || Int(statusCode) == Int(r5_status_connection_close.rawValue)){
            SOConnected = false
        }
    }
    
    var inputWait = false
    @objc func roomConnectDisconnect () {
        if (!SOConnected) {
            if(inputWait){
                return;
            }
            NSLog("%@", "Sending shared object connection request")
            sObject = R5SharedObject(name:roomInput?.text, connection: connection);
            sObject?.client = self;
            inputWait = true;
        } else {
            sObject?.close();
            sObject?.client = nil;
            sObject = nil;
            SOConnected = false
            addMessage(message: "Disconnected from " + roomInput!.text + ".");
            
            connection?.delegate = nil
            connection?.client = nil
            connection?.stopDataOnlyStream()
            
            startConnection()
        }
        connectBtn?.setTitle(SOConnected ? "Disconnect From SO" : "Connect To SO", for: UIControl.State.normal)
        sendBtn?.isEnabled = SOConnected
    }
    
    @objc override func SOConnect(){
        // fall through.
    }
    
    override func closeTest() {
        if( self.timer != nil ){
            self.timer?.invalidate()
        }
        if(sObject != nil){
            sObject?.client = nil
            
            if(SOConnected){
                sObject?.close()
                sObject = nil
                SOConnected = false
            }
        }
        
        sendBtn?.isEnabled = SOConnected
        connection?.stopDataOnlyStream()
    }
    
    //inherited methods need to be overriden to expose them for use as callbacks
    @objc override func onSharedObjectConnect( objectValue: NSDictionary){
        SOConnected = true;
        inputWait = false;
        addMessage(message: "Connected to " + roomInput!.text + ".")
        connectBtn?.setTitle(SOConnected ? "Disconnect From SO" : "Connect To SO", for: UIControl.State.normal)
        sendBtn?.isEnabled = SOConnected
        let data : NSMutableDictionary? = (sObject?.data)
        if (data?["color"] != nil) {
            setChatViewToHex(hexString: data!["color"] as! String)
        }
    }
    @objc override func onUpdateProperty(propertyInfo: [AnyHashable : Any]) {
        super.onUpdateProperty(propertyInfo: propertyInfo);
    }
    @objc override func messageTransmit(messageIn: [AnyHashable : Any]) {
        super.messageTransmit(messageIn: messageIn);
    }
}
