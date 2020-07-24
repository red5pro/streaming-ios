//
//  ConferenceTest.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 5/4/20.
//  Copyright © 2020 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(ConferenceTest)
class ConferenceTest: BaseTest, ConferenceViewControllerDelegate {
    
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
    var roomSO : R5SharedObject? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        
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
                        thisTest.connectSO()
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
                                Timer.scheduledTimer(timeInterval: 0.25, target: self.thisTest, selector: #selector(connectSO), userInfo: nil, repeats: false)
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
    // v SHARED OBJECT v
    
    @objc func connectSO() {
        if(self.streams.count < 1) {
            return
        }
        self.roomSO = R5SharedObject(name: self.roomName!, connection: self.streams[0].stream?.connection)
        self.roomSO?.client = self
    }
    
    @objc func onSharedObjectConnect( objectValue: NSDictionary) {
        let data : NSMutableDictionary = (roomSO?.data)!
        var streamString = ""
        if(data.object(forKey: "streams") != nil) {
            streamString = data.object(forKey: "streams") as! String
        }
        if(streamString.isEmpty || ((overlay?.clearOn) != nil)) {
            streamString = pubName!
        } else {
            stringToQueue(incoming: streamString)
            streamString.append(",")
            streamString.append(pubName!)
        }
        overlay?.clearOn = false
        roomSO?.setProperty("streams", withValue: streamString as NSString)
    }
    
    @objc func onUpdateProperty( propertyInfo: [AnyHashable: Any] ) {
        if let c = propertyInfo["streams"] {
            stringToQueue(incoming: c as! String)
        }
    }
    
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
        
        if(startQueue) {
            if(subQueue!.count < 1) {
                subQueue = nil
            } else {
                nextSubInQueue()
            }
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
            self.removeView(r5View: (targetPack?.view)!)
            targetPack?.stream!.delegate = nil
            targetPack?.stream!.stop()
            self.streams.removeAll { (pack : StreamPackage) -> Bool in
                return targetPack?.name! == pack.name!
            }
        }
    }
    
    // ^ SHARED OBJECT ^

    // v VIEWS V
    
    func addTag(r5View : R5VideoViewController, tagName : String) {
        let tag = UITextView()
        tag.text = tagName
        r5View.view.addSubview(tag)
    }
    
    let targetRatio : CGFloat = 1.0
    func addNewView(r5View : R5VideoViewController) {
        self.view.insertSubview(r5View.view, belowSubview: (overlay?.view)!)
        if(rowCount < 1) {
            rowCount = 1
            columnCount = 1
        }
        if(rowCount * columnCount < streams.count){
            let screenSize = self.view.bounds.size
            let width = screenSize.width
            let height = screenSize.height
            let newRowRatio = (width/CGFloat(columnCount)) / (height/CGFloat(rowCount+1))
            let newColumnRatio = (width/CGFloat(columnCount+1)) / (height/CGFloat(rowCount))
            
            if(abs(newColumnRatio - targetRatio) < abs(newRowRatio - targetRatio)) {
                columnCount += 1
            } else {
                rowCount += 1
            }
        }
        
        arrangeViews()
    }
    
    func removeView(r5View : R5VideoViewController) {
        
        r5View.view.removeFromSuperview()
        
        let screenSize = self.view.bounds.size
        let width = screenSize.width
        let height = screenSize.height
        let lessRowRatio = (width/CGFloat(columnCount)) / (height/CGFloat(rowCount-1))
        let lessColumnRatio = (width/CGFloat(columnCount-1)) / (height/CGFloat(rowCount))
        
        if(abs(lessColumnRatio - targetRatio) < abs(lessRowRatio - targetRatio)) {
            if((columnCount-1)*rowCount >= streams.count) {
                columnCount -= 1
            }
        }
        else {
            if((rowCount-1)*columnCount >= streams.count) {
                rowCount -= 1
            }
        }
        
        arrangeViews()
    }
    
    func arrangeViews() {
        arrangeViews(withSize: self.view.bounds.size)
    }
    func arrangeViews(withSize : CGSize) {
        let viewWidth = withSize.width / CGFloat(columnCount)
        let viewHeight = withSize.height / CGFloat(rowCount)
        
        var i : Int = 0
        for y : Int in 0..<rowCount {
            for x : Int in 0..<columnCount {
                if(i < streams.count) {
                    streams[i].view?.setFrame(CGRect(x: CGFloat(x)*viewWidth, y: CGFloat(y)*viewHeight, width: viewWidth, height: viewHeight))
                    i += 1
                }
            }
        }
    }
    
    // ^ VIEWS ^
    
    override func closeTest() {
        
        if(roomSO != nil) {
            var streamString = roomSO?.data.object(forKey: "streams") as! String
            var streamList = streamString.split(separator: ",")
            streamList.removeAll { (s) -> Bool in
                return String(s) == pubName
            }
            streamString = streamList.joined(separator: ",")
            roomSO?.setProperty("streams", withValue: streamString as NSString)
            
            roomSO?.client = nil
            roomSO?.close()
        }
        if(streams.count > 0) {
            for pack in streams {
                pack.view?.attach(nil)
                pack.stream?.delegate = nil
                pack.stream?.stop()
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
