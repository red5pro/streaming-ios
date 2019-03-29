//
//  SubscribeSetVolumeTest.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 08/28/2018.
//  Copyright © 2018 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeSetVolumeTest)
class SubscribeSetVolumeTest: BaseTest {
    
    var slider: UISlider?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupDefaultR5VideoViewController()
        
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
        
        currentView?.attach(subscribeStream)
        
        self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String)
        
        let f = self.view.frame
        slider = UISlider(frame: CGRect(x:40, y:f.size.height - 40, width:f.size.width - 80, height:20))
        slider?.minimumValue = 0
        slider?.maximumValue = 100
        slider?.isContinuous = true
        slider?.tintColor = UIColor.blue
        slider?.value = 100
        slider?.addTarget(self, action: #selector(SubscribeSetVolumeTest.sliderValueDidChange(sender:)), for: .valueChanged)
        self.view.addSubview(slider!)

    }
    
    func sliderValueDidChange(sender:UISlider!) {
        self.subscribeStream?.audioController.volume = slider!.value / 100
    }
    
    override func viewDidLayoutSubviews() {
        

        if(currentView != nil){
            
           // currentView?.setFrame(view.frame);
        }
        
    }

}
