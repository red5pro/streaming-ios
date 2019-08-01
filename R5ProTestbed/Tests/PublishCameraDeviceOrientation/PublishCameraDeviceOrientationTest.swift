//
//  PublishCameraDeviceOrientationTest.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 06/17/19.
//  Copyright © 2019 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(PublishCameraDeviceOrientationTest)
class PublishCameraDeviceOrientationTest: BaseTest {

    var uiv : UIImageView? = nil
    var tapGesture : UIGestureRecognizer?
    
    var camOrientation = 90
    
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
        rotated();
        
        self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: getPublishRecordType ())
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        self.view.addGestureRecognizer(tap)
        self.tapGesture = tap
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        
        if let tapGesture = tapGesture {
            self.view.removeGestureRecognizer(tapGesture)
        }
        
    }
    
    @objc func handleSingleTap(_ recognizer : UITapGestureRecognizer) {
        
        var frontCamera : AVCaptureDevice?
        var backCamera : AVCaptureDevice?
        
        for device in AVCaptureDevice.devices(for: AVMediaType.video){
            let device = device
            if frontCamera == nil && device.position == AVCaptureDevice.Position.front {
                frontCamera = device
                continue;
            } else if backCamera == nil && device.position == AVCaptureDevice.Position.back{
                backCamera = device
            }
        }
        
        let camera = self.publishStream?.getVideoSource() as! R5Camera
        if (camera.device === frontCamera) {
            camera.device = backCamera;
        } else {
            camera.device = frontCamera;
        }
        rotated()
        camera.orientation = Int32(camOrientation)
        
    }
    
    @objc func rotated() {
        
        let cam = self.publishStream?.getVideoSource() as! R5Camera
        let pos = cam.device.position
        
        switch UIDevice.current.orientation {
            case .landscapeLeft:
                if pos == AVCaptureDevice.Position.front {
                    cam.orientation = 180;
                } else {
                    cam.orientation = 0;
                }
            case .landscapeRight:
                if pos == AVCaptureDevice.Position.front {
                    cam.orientation = 0;
                } else {
                    cam.orientation = 180;
                }
            case .portrait:
                cam.orientation = 90;
            case .portraitUpsideDown:
                cam.orientation = 270;
            case .unknown:
                cam.orientation = 90;
            default:
                cam.orientation = 90;
        }
        
        camOrientation = Int(cam.orientation)
        
    }
    
    override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        super.onR5StreamStatus(stream, withStatus: statusCode, withMessage: msg)
        if (Int(statusCode) == Int(r5_status_buffer_flush_start.rawValue)) {
            NotificationCenter.default.post(Notification(name: Notification.Name("BufferFlushStart")))
        }
        else if (Int(statusCode) == Int(r5_status_buffer_flush_empty.rawValue)) {
            NotificationCenter.default.post(Notification(name: Notification.Name("BufferFlushComplete")))
        }
    }

}
