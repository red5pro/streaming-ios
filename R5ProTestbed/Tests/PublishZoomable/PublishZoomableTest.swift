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
    var slider : UISlider? = nil;
    
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
        
        self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: getPublishRecordType ())
        
        let screenSize = UIScreen.main.bounds.size
        
        slider = UISlider(frame: CGRect(x:90, y:UIScreen.main.bounds.height - 30, width:screenSize.width - 180, height:20))
        slider?.minimumValue = 1
        slider?.maximumValue = 5
        slider?.isContinuous = true
        slider?.tintColor = UIColor.red
        slider?.value = 1
        slider?.isEnabled = false
//        slider?.addTarget(self, action:  #selector(PublishZoomableTest.sliderValueDidChange(sender:)), for: .valueChanged)
        self.view.addSubview(slider!)
        
        let downBtn = UIButton(frame: CGRect(x: 20, y: screenSize.height - 40, width: 50, height: 34))
        downBtn.backgroundColor = UIColor.darkGray
        downBtn.setTitle("-", for: UIControl.State.normal)
        view.addSubview(downBtn)
        let tap = UITapGestureRecognizer(target: self, action: #selector(onZoomOut))
        downBtn.addGestureRecognizer(tap)
        
        let upBtn = UIButton(frame: CGRect(x: screenSize.width - 70, y: screenSize.height - 40, width: 50, height: 34))
        upBtn.backgroundColor = UIColor.darkGray
        upBtn.setTitle("+", for: UIControl.State.normal)
        view.addSubview(upBtn)
        let tapIn = UITapGestureRecognizer(target: self, action: #selector(onZoomIn))
        upBtn.addGestureRecognizer(tapIn)
        
    }
    
    @objc func onZoomOut () {
        let v = (slider?.value)! - 0.5 < 1 ? 1 : (slider?.value)! - 0.5
        updateSliderValue(value: v)
    }
    
    @objc func onZoomIn () {
        let v = (slider?.value)! + 0.5 > 5 ? 5 : (slider?.value)! + 0.5
        updateSliderValue(value: v)
    }
    
    func updateSliderValue(value: Float!) {
        do {
            try cam!.lockForConfiguration()
            cam!.ramp(toVideoZoomFactor: CGFloat(value), withRate: 1.0)
            cam!.unlockForConfiguration()
            slider?.setValue(value, animated: true)
        } catch {
            //
        }
    }
}
