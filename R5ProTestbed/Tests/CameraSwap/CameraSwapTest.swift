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

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in
            
        };
        
        
        setupDefaultR5VideoViewController()
        
        // Set up the configuration
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        
        setupPublisher(connection: connection!)
        // show preview and debug info
        
        self.currentView!.attach(publishStream!)
        
        
        self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: R5RecordTypeLive)
        
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CameraSwapTest.handleSingleTap(_:)))
        
        self.view.addGestureRecognizer(tap)
        
    }
    
    func handleSingleTap(_ recognizer : UITapGestureRecognizer) {
        
       //change which camera is being used!!!
        
        //get front and back camera!!!!
        
        var frontCamera : AVCaptureDevice?
        var backCamera : AVCaptureDevice?
        
        for device in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo){
            let device = device as! AVCaptureDevice
            if frontCamera == nil && device.position == AVCaptureDevicePosition.front {
                frontCamera = device
                continue;
            }else if backCamera == nil && device.position == AVCaptureDevicePosition.back{
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
