//
//  PublishStreamImageTest.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/17/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(PublishDeviceOrientationTest)
class PublishDeviceOrientationTest: BaseTest {

    var uiv : UIImageView? = nil
    
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
        
        self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: R5RecordTypeLive)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PublishDeviceOrientationTest.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
    }
    
    func rotated() {
        
        let cam = self.publishStream?.getVideoSource() as! R5Camera
        let orientation = UIApplication.shared.statusBarOrientation;
        
        switch UIDevice.current.orientation {
            case .landscapeLeft:
                cam.orientation = 180;
            case .landscapeRight:
                cam.orientation = 0;
            case .portrait:
                cam.orientation = 90;
            case .portraitUpsideDown:
                cam.orientation = 270;
            case .unknown:
                cam.orientation = 90;
            default:
                cam.orientation = 90;
        }
        
    }

}
