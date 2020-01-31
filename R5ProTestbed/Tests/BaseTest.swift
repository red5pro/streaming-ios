//
//  BaseTest.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/16/15.
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

enum AccessError: Error {
    case error(message: String)
}

extension AccessError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error:
            return NSLocalizedString("Unable to fetch stream for action subscribe.", comment: "Access Error")
        }
    }
}

@objc(BaseTest)
class BaseTest: UIViewController , R5StreamDelegate {
    
    func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        let s =  String(format: "Status: %s (%@)",  r5_string_for_status(statusCode), msg)
        NSLog(s)
        ALToastView.toast(in: self.view, withText:s)
        
        if (Int(statusCode) == Int(r5_status_disconnected.rawValue)) {
            self.cleanup()
        }
        else if (Int(statusCode) == Int(r5_status_video_render_start.rawValue)) {
            NSLog("SUPPORT-482 %@", msg);
        }
    }
    
    var shouldClose : Bool = true
    var currentView : R5VideoViewController? = nil
    var publishStream : R5Stream? = nil
    var subscribeStream : R5Stream? = nil
    
    required init () {
       
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func cleanup () {
        if( self.publishStream != nil ) {
            self.publishStream!.client = nil
            self.publishStream?.delegate = nil
            self.publishStream = nil
        }
        
        if( self.subscribeStream != nil ) {
            self.subscribeStream!.client = nil
            self.subscribeStream?.delegate = nil
            self.subscribeStream = nil
        }
        self.removeFromParent()
    }
    
    func closeTest(){
        
        NSLog("closing view")

        if( self.publishStream != nil ){
            self.publishStream!.stop()
        }
        
        if( self.subscribeStream != nil ){
            self.subscribeStream!.stop()
        }
        
        // Moved to status disconnect, due to publisher emptying queue buffer on bad connections.
//        self.removeFromParentViewController()
    }
    
    func getConfig()->R5Configuration{
        // Set up the configuration
        let config = R5Configuration()
        config.host = Testbed.getParameter(param: "host") as! String
        config.port = Int32(Testbed.getParameter(param: "port") as! Int)
        config.contextName = Testbed.getParameter(param: "context") as! String
        config.`protocol` = Int32(r5_rtsp.rawValue);
        config.buffer_time = (Testbed.getParameter(param: "buffer_time")?.floatValue)!
        config.licenseKey = Testbed.getParameter(param: "license_key") as! String
        return config
    }
    
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        if(currentView != nil){
            
            currentView?.setFrame(view.frame);
        }
        
    }
    
    func setupPublisher(connection: R5Connection){
        
        self.publishStream = R5Stream(connection: connection)
        self.publishStream!.delegate = self
        
        if(Testbed.getParameter(param: "video_on") as! Bool){
            // Attach the video from camera to stream
            let videoDevice = AVCaptureDevice.devices(for: AVMediaType.video).last as? AVCaptureDevice
            
            let camera = R5Camera(device: videoDevice, andBitRate: Int32(Testbed.getParameter(param: "bitrate") as! Int))
           
            camera?.width = Int32(Testbed.getParameter(param: "camera_width") as! Int)
            camera?.height = Int32(Testbed.getParameter(param: "camera_height") as! Int)
            camera?.fps = Int32(Testbed.getParameter(param: "fps") as! Int)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in
            
        };
        
        r5_set_log_level((Int32)(r5_log_level_debug.rawValue))
        
        self.view.autoresizesSubviews = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        //this is just to have a white background to the example
        let backView : UIView = UIView(frame: self.view.frame);
        backView.backgroundColor = UIColor.white;
        self.view.addSubview(backView);
        
    }
    
    func getPublishRecordType () -> R5RecordType {
        var type = R5RecordTypeLive
        if Testbed.getParameter(param: "record_on") as! Bool {
            type = R5RecordTypeRecord
            if Testbed.getParameter(param: "append_on") as! Bool {
                type = R5RecordTypeAppend
            }
        }
        return type
    }
    
    func setupDefaultR5VideoViewController() -> R5VideoViewController{
        
        currentView = getNewR5VideoViewController(rect: self.view.frame)
        
        self.addChild(currentView!)
        self.view.addSubview(currentView!.view)
        
        currentView?.setFrame(self.view.bounds)
        
        currentView?.showPreview(true)

        currentView?.showDebugInfo(Testbed.getParameter(param: "debug_view") as! Bool)
        
        return currentView!
    }
    
    func getNewR5VideoViewController(rect : CGRect) -> R5VideoViewController {
        
        let view : UIView = UIView(frame: rect)
        
        var r5View : R5VideoViewController
        r5View = R5VideoViewController.init()
        r5View.view = view;
        
        return r5View;
            
    }
    
    open override var shouldAutorotate:Bool {
        get {
            return true
        }
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return [UIInterfaceOrientationMask.all]
        }
    }

}
