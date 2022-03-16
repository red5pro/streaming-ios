//
//  ConferenceTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 5/4/20.
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

@objc(ConferenceTest)
class ConferenceTest: BaseTest, ConferenceViewControllerDelegate, WebSocketProviderDelegate {
    
    var videoOn = true
    var audioOn = true
    var muteLock = true
    var rowCount : Int = 0
    var columnCount : Int = 0
    
    var overlay : ConferenceViewController? = nil
    
    var pubName : String? = nil
    var roomName : String? = nil
    
    var config : R5Configuration? = nil
    var streams : [StreamPackage] = []
    var subQueue : [String]? = nil
    
    var socket: WebSocketProvider? = nil
    
    var timer : Timer? = nil
    
    // Force portrait.
    open override var shouldAutorotate:Bool {
        get {
            return false
        }
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        UIView.setAnimationsEnabled(false)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIView.setAnimationsEnabled(true)
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in
           
        };
         
        //add view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        overlay = (storyboard.instantiateViewController(withIdentifier: "ConferenceViewController") as? ConferenceViewController)!
        overlay?.view.frame = CGRect(x:0, y:0, width:self.view.frame.width, height: self.view.frame.height)
        
        self.addChild(overlay!)
        self.view.addSubview((overlay?.view)!)
        overlay?.view.layoutSubviews()
        overlay?.view.backgroundColor = UIColor(white: 1, alpha: 0.0)
        overlay?.delegate = self
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(rootTouch(_:)))
        self.view.addGestureRecognizer(tap)
        
        self.view.backgroundColor = UIColor.gray
        
        config = getConfig()
    }

    // v BUTTONS v
    
    @objc func rootTouch(_ recognizer : UITapGestureRecognizer) {
//        overlay?.toggleMuteVisibility()
        overlay?.streamNameField.resignFirstResponder()
        overlay?.roomNameField.resignFirstResponder()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        arrangeViews(withSize: size)
    }
    
    func connectTrigger() {
        pubName = overlay?.streamNameField.text
        roomName = overlay?.roomNameField.text
        overlay?.streamNameField.resignFirstResponder()
        overlay?.roomNameField.resignFirstResponder()
        publish();
    }
    
    func videoMuteTrigger() {
        videoOn = !videoOn
        if(streams.count > 0){
            streams[0].view?.view.alpha = (videoOn ? 1.0 : 0.5)
        }
        if(!muteLock){
            streams[0].stream?.pauseVideo = !videoOn
        }
        overlay?.streamNameField.resignFirstResponder()
        overlay?.roomNameField.resignFirstResponder()
    }
    
    func audioMuteTrigger() {
        audioOn = !audioOn
        if(!muteLock){
            streams[0].stream?.pauseAudio = !audioOn
        }
        overlay?.streamNameField.resignFirstResponder()
        overlay?.roomNameField.resignFirstResponder()
    }
    
    // ^ BUTTONS ^
    
    // v STREAMS v
    
    func publish() {
        
        let pack = StreamPackage()
        pack.name = pubName
        streams.append(pack)
        
        pack.view = getNewR5VideoViewController(rect: self.view.bounds)
        addNewView(r5View: pack.view!)
        addTag(r5View: pack.view!, tagName: pack.name!)
        
        pack.view!.showPreview(true)
        
        config?.contextName = (Testbed.getParameter(param: "context") as! String) + "/" + roomName!
        let connection = R5Connection(config: config)
        
        pack.stream = R5Stream(connection: connection)
        pack.stream?.client = self
        pack.stream!.delegate = ConferenceConnListener(theTest: self, streamName: pubName!, isPublish: true)
        
        // Attach the video from camera to stream
        let videoDevice = AVCaptureDevice.devices(for: AVMediaType.video).last as? AVCaptureDevice
        
        let camera = R5Camera(device: videoDevice, andBitRate: Int32(Testbed.getParameter(param: "bitrate") as! Int))
       
        camera?.width = Int32(Testbed.getParameter(param: "camera_width") as! Int)
        camera?.height = Int32(Testbed.getParameter(param: "camera_height") as! Int)
        camera?.fps = Int32(Testbed.getParameter(param: "fps") as! Int)
        camera?.orientation = 90
        pack.stream!.attachVideo(camera)
        
        // Attach the audio from microphone to stream
        let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
        let microphone = R5Microphone(device: audioDevice)
        microphone?.bitrate = 32
        NSLog("Got device %@", String(describing: audioDevice?.localizedName))
        pack.stream!.attachAudio(microphone)
        
        pack.view!.attach(pack.stream!)
        
        pack.stream!.publish(pubName, type: getPublishRecordType ())
    }
    
    func subscribe(toName : String) {
        let pack = StreamPackage()
        pack.name = toName
        streams.append(pack)
        
        pack.view = getNewR5VideoViewController(rect: self.view.bounds)
        addTag(r5View: pack.view!, tagName: toName)
        
        let connection = R5Connection(config: config)
        
        pack.stream = R5Stream(connection: connection)
        
        pack.stream!.audioController = R5AudioController()
        pack.stream?.client = self;
        pack.stream?.delegate = ConferenceConnListener(theTest: self, streamName: toName, isPublish: false)
        
        pack.view?.attach(pack.stream!)
        pack.stream?.play(toName, withHardwareAcceleration:Testbed.getParameter(param: "hwaccel_on") as! Bool)
    }
    
    class ConferenceConnListener : NSObject, R5StreamDelegate {
        
        var thisTest : ConferenceTest
        var name : String
        var pub : Bool
        var calledForNextInQueue : Bool
        var dead = false
        
        init( theTest : ConferenceTest, streamName : String, isPublish : Bool) {
            thisTest = theTest
            name = streamName
            pub = isPublish
            calledForNextInQueue = pub
        }
        
        func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
            if(dead) {
                return
            }
            
            NSLog("Event for %@ is: %s - %@", pub ? "Publisher" : "Stream: " + name, r5_string_for_status(statusCode), msg)
            
            if(!calledForNextInQueue && statusCode == r5_status_connected.rawValue && thisTest.subQueue != nil) {
                thisTest.nextSubInQueue()
                calledForNextInQueue = true
            }
            
            if(statusCode == r5_status_start_streaming.rawValue) {
                if(pub){
                    if(thisTest.videoOn && thisTest.audioOn) {
                        thisTest.muteLock = false
                        thisTest.connectToListServer()
                    } else {
                        let waitTime = DispatchTime(uptimeNanoseconds: DispatchTime.now().uptimeNanoseconds + 500000) //0.5s as ns
                        DispatchQueue.main.asyncAfter(deadline: waitTime) {
                            if(self.thisTest.streams.count > 0){
                                self.thisTest.muteLock = false
                                let targStream = self.thisTest.streams[0].stream!
                                if(!self.thisTest.videoOn) {
                                    targStream.pauseVideo = true
                                }
                                if(!self.thisTest.audioOn) {
                                    targStream.pauseAudio = true
                                }
                                
                                if (self.thisTest.timer != nil) {
                                    self.thisTest.timer?.invalidate()
                                    self.thisTest.timer = nil
                                }
                                self.thisTest.timer = Timer.scheduledTimer(timeInterval: 0.25, target: self.thisTest, selector: #selector(connectToListServer), userInfo: nil, repeats: false)
                                
                            }
                        }
                    }
                }
                else{
                    DispatchQueue.main.async {
                        let pack = self.thisTest.packByName(packName: self.name)
                        if(pack != nil){
                            self.thisTest.addNewView(r5View: pack!.view!)
                        }
                    }
                }
            }
            
            if(statusCode == r5_status_connection_error.rawValue || statusCode == r5_status_disconnected.rawValue
                || statusCode == r5_status_connection_close.rawValue) {
                dead = true
                if(pub) {
                    DispatchQueue.main.async {
                        self.thisTest.closeTest()
                    }
                } else {
                    thisTest.clearByName(clearName: name)
                    if(!calledForNextInQueue && thisTest.subQueue != nil) {
                        thisTest.nextSubInQueue()
                    }
                }
            }
        }
    }
    
    func nextSubInQueue() {
        if(subQueue!.count > 0) {
            DispatchQueue.main.async {
                let nextSub = self.subQueue![0]
                self.subQueue!.remove(at: 0)
                self.subscribe(toName: nextSub)
            }
        } else {
            subQueue = nil
        }
    }
    
    // ^ STREAMS ^
    
    @objc func connectToListServer () {
        connectSocket()
    }
    
    // v SOCKET v
    
    @objc func connectSocket () {
        // Endpoint location of host. See: https://github.com/red5pro/red5pro-conference-host
        // Note: Even though you may launch the conference host server on localhost, you cannot
        //          specify `localhost` in the URL. You need to define the private IP of your machine on the
        //          same router that the tethered iOS device is on (e.g., 10.0.0.x).
        //          This is because defining `localhost` as the endpoint here would indicate your iOS device.
        let host = Testbed.getParameter(param: "conference_host" as String)?
            .replacingOccurrences(of: "http:", with:"ws:")
            .replacingOccurrences(of: "https:", with: "wss:")
        let url = URL(string: "\(host!)?room=\(self.roomName!)&streamName=\(self.pubName!)")
        socket = WebSocketProvider(url: url!)
        socket?.delegate = self
        socket?.connect()
    }
    
    func webSocketDidConnect(_ webSocket: WebSocketProvider) {}
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {}
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveMessage message: String) {
        // message = { room: str, streams: str[] }
        let json: AnyObject? = message.parseJSONString
        let jsonDict = json as? [String: Any]
        
        if jsonDict?["room"] as? String == self.roomName! {
            if let streams = jsonDict?["streams"] as? Array<String> {
                stringToQueue(incoming: streams.joined(separator: ","))
            }
        }
    }
    
    // ^ SOCKET ^
    
    func stringToQueue(incoming : String) {
              
        var startQueue = false
        if(subQueue == nil) {
            subQueue = []
            startQueue = true
        }
        let split = incoming.split(separator: ",")
        for s in split {
            var found = false
            if(packByName(packName: String(s)) != nil){
                found = true
            }
            for queueS in subQueue! {
                if(String(s) == queueS) {
                    found = true
                    break
                }
            }
            if(!found) {
                subQueue?.append(String(s))
            }
        }
        
        if (startQueue) {
            if(subQueue!.count < 1) {
                subQueue = nil
            } else {
                nextSubInQueue()
            }
        } else if (subQueue != nil && subQueue!.count < 1) {
            nextSubInQueue()
        }
        
        var allActiveNames : [String] = []
        for pack in streams {
            allActiveNames.append(pack.name!)
        }
        if(subQueue != nil){
            allActiveNames.append(contentsOf: subQueue!)
        }
        for s in split {
            allActiveNames.removeAll { (activeS : String) -> Bool in
                return activeS == String(s)
            }
        }
        allActiveNames.removeAll { (activeS : String) -> Bool in
            return activeS == pubName!
        }
        
        for activeS in allActiveNames {
            DispatchQueue.main.async {
                self.clearByName(clearName: activeS)
            }
        }
    }
    
    func packByName(packName : String) -> StreamPackage? {
        for pack in streams {
            if(pack.name! == packName) {
                return pack
            }
        }
        return nil
    }
    
    func clearByName(clearName : String) {
        let targetPack : StreamPackage? = packByName(packName: clearName)
        
        if(targetPack == nil) {
            return
        }
        
        DispatchQueue.main.async {
            targetPack?.stream!.delegate = nil
            targetPack?.stream!.stop()
            if (targetPack?.view != nil) {
                self.removeView(r5View: (targetPack?.view)!)
            }
            self.streams.removeAll { (pack : StreamPackage) -> Bool in
                return targetPack?.name! == pack.name!
            }
            self.arrangeViews()
        }
    }

    // v VIEWS V
    
    func addTag(r5View : R5VideoViewController, tagName : String) {
        let tag = UITextView()
        tag.text = tagName
        r5View.view.addSubview(tag)
    }
    
    let targetRatio : CGFloat = 1.0
    func addNewView(r5View : R5VideoViewController) {
        self.view.insertSubview(r5View.view, belowSubview: (overlay?.view)!)
        arrangeViews()
    }
    
    func removeView(r5View : R5VideoViewController) {
        r5View.view.removeFromSuperview()
        r5View.removeFromParent()
        arrangeViews()
    }
    
    func arrangeViews() {
        arrangeViews(withSize: self.view.bounds.size)
    }
    
    func arrangeViews(withSize : CGSize) {
        
        columnCount = streams.count == 2 ? 1 : streams.count > 2 ? 2 : 1
        rowCount = streams.count == 2 ? 2 : Int(ceil(Double(streams.count) / 2.0))
        
        let viewWidth = withSize.width / CGFloat(columnCount)
        let viewHeight = withSize.height / CGFloat(rowCount)
        var i : Int = 0
        var row : Int = 0
        
        for stream : StreamPackage in streams {
            
            let view = streams[i].view
            if (i >= 2) {
                row += i % 2 == 0 ? 1 : 0
            }
            
            // If only 2, First 2 are stacked.
            if streams.count <= 2 {
                
                view?.setFrame(CGRect(x: 0, y: CGFloat(i)*viewHeight, width: withSize.width, height: viewHeight))
                
            } else if i % 2 == 0 && i == streams.count - 1 {
                
                // Last one, if not 2 in the last row, is stretched to width
                view?.setFrame(CGRect(x: 0, y: CGFloat(rowCount-1)*viewHeight, width: withSize.width, height: viewHeight))
                
            } else {
                
                // Else equal grid
                view?.setFrame(CGRect(x: (i % 2 == 0) ? viewWidth : 0, y: CGFloat(row)*viewHeight, width: viewWidth, height: viewHeight))
                
            }
            
            i += 1
            
        }
    }
    
    // ^ VIEWS ^
    
    override func closeTest() {
        
        if (socket != nil) {
            socket?.disconnect()
            socket = nil
        }
        
        if (timer != nil) {
            timer?.invalidate()
            timer = nil
        }
        
        if(streams.count > 0) {
            for i in stride(from:streams.count - 1, through:0, by: -1) {
                let pack = streams[i]
//            for pack in streams {
                pack.stream?.client = nil
                pack.stream?.delegate = nil
                clearByName(clearName: pack.name!)
            }
            streams.removeAll()
        }
        if(subQueue != nil) {
            subQueue?.removeAll()
            subQueue = nil
        }
        
        super.closeTest()
    }
}

class StreamPackage {
    var stream : R5Stream? = nil
    var view : R5VideoViewController? = nil
    var name : String? = nil
}
