//
//  CameraSwapTest.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/17/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(CameraSwapTest)
class CameraSwapTest: BaseTest {

    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in
            
        };
        
        
        setupDefaultR5VideoViewController()
        
        // Set up the configuration
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        
        setupPublisher(connection)
        // show preview and debug info
        
        self.currentView!.attachStream(publishStream!)
        
        
        self.publishStream!.publish(Testbed.getParameter("stream1") as! String, type: R5RecordTypeLive)
        
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        
        self.view.addGestureRecognizer(tap)
        
    }
    
    func handleSingleTap(recognizer : UITapGestureRecognizer) {
        
       //change which camera is being used!!!
        
        //get front and back camera!!!!
        
        var frontCamera : AVCaptureDevice?
        var backCamera : AVCaptureDevice?
        
        for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo){
            let device = device as! AVCaptureDevice
            if frontCamera == nil && device.position == AVCaptureDevicePosition.Front {
                frontCamera = device
                continue;
            }else if backCamera == nil && device.position == AVCaptureDevicePosition.Back{
                backCamera = device
            }
            
        }
        
        let camera = self.publishStream?.getVideoSource() as! R5Camera

        if(camera.device === frontCamera){
            camera.device = backCamera;
        }else{
            camera.device = frontCamera;
        }
        
        
    }


}
