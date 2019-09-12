//
//  PublishZoomableTest.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 12/16/15.
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
