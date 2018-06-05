//
//  PublishZoomableTest.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 12/16/15.
//  Copyright © 2018 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(PublishZoomableTest)
class PublishZoomableTest: BaseTest {

    var cam : AVCaptureDevice? = nil;
    
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
        cam = (self.publishStream?.getVideoSource() as! R5Camera).device
        
        // show preview and debug info
        // self.publishStream?.getVideoSource().fps = 2;
        self.currentView!.attach(publishStream!)
        
        self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: R5RecordTypeLive)
        
        var slider = UISlider(frame: CGRect(x:20, y:UIScreen.main.bounds.height - 40, width:280, height:20))
        slider.minimumValue = 1
        slider.maximumValue = 5
        slider.isContinuous = true
        slider.tintColor = UIColor.red
        slider.value = 1
        slider.addTarget(self, action:  #selector(PublishZoomableTest.sliderValueDidChange(sender:)), for: .valueChanged)
        self.view.addSubview(slider)
        
    }
    
    func sliderValueDidChange(sender:UISlider!) {
        do {
            try cam!.lockForConfiguration()
            cam!.ramp(toVideoZoomFactor: CGFloat(sender.value), withRate: 1.0)
            cam!.unlockForConfiguration()
        } catch {
            //
        }
    }
}
