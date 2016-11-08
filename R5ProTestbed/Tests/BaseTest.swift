//
//  BaseTest.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/16/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(BaseTest)
class BaseTest: UIViewController , R5StreamDelegate {
    
    func onR5StreamStatus(stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        NSLog("Status: %s ", r5_string_for_status(statusCode))
        let s =  String(format: "Status: %s (%@)",  r5_string_for_status(statusCode), msg)
        
        ALToastView.toastInView(self.view, withText:s)
    }
    
    var currentView : R5VideoViewController? = nil
    var publishStream : R5Stream? = nil
    var subscribeStream : R5Stream? = nil
    
    required init () {
       
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func closeTest(){
        
        NSLog("closing view")

        if( self.publishStream != nil ){
            self.publishStream!.stop()
        }
        
        if( self.subscribeStream != nil ){
            self.subscribeStream!.stop()
        }
        
        self.removeFromParentViewController()
    }
    
    func getConfig()->R5Configuration{
        // Set up the configuration
        let config = R5Configuration()
        config.host = Testbed.getParameter("host") as! String
        config.port = Int32(Testbed.getParameter("port") as! Int)
        config.contextName = Testbed.getParameter("context") as! String
        config.`protocol` = 1;
        config.buffer_time = Testbed.getParameter("buffer_time") as! Float
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
        
        if(Testbed.getParameter("video_on") as! Bool){
            // Attach the video from camera to stream
            let videoDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).last as? AVCaptureDevice
            
            let camera = R5Camera(device: videoDevice, andBitRate: Int32(Testbed.getParameter("bitrate") as! Int))
            camera.width = Int32(Testbed.getParameter("camera_width") as! Int)
            camera.height = Int32(Testbed.getParameter("camera_height") as! Int)
            camera.orientation = 90
            self.publishStream!.attachVideo(camera)
        }
        if(Testbed.getParameter("audio_on") as! Bool){
            // Attach the audio from microphone to stream
            let audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
            let microphone = R5Microphone(device: audioDevice)
            microphone.bitrate = 32
            microphone.device = audioDevice;
            NSLog("Got device %@", audioDevice)
            self.publishStream!.attachAudio(microphone)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in
            
        };
        
        r5_set_log_level((Int32)(r5_log_level_debug.rawValue))
        
        self.view.autoresizesSubviews = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //this is just to have a white background to the example
        let backView : UIView = UIView(frame: self.view.frame);
        backView.backgroundColor = UIColor.whiteColor();
        self.view.addSubview(backView);
        
    }
    
    func setupDefaultR5VideoViewController() -> R5VideoViewController{
        
        let r5View : R5VideoViewController = getNewR5VideoViewController(self.view.frame);
        self.addChildViewController(r5View);
        
        
        view.addSubview(r5View.view)
        
        r5View.showPreview(true)

        r5View.showDebugInfo(Testbed.getParameter("debug_view") as! Bool)

        currentView = r5View;
        
        return currentView!
    }
    
    func getNewR5VideoViewController(rect : CGRect) -> R5VideoViewController{
        
        let view : UIView = UIView(frame: rect)
        
        let r5View : R5VideoViewController = R5VideoViewController();
        r5View.view = view;
        
        return r5View;
    }

}
