//
//  SubscribeMuteTest.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 05/21/2018.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeMuteTest)
class SubscribeMuteTest: BaseTest {

    var current_rotation = 0;
    var toggleBtn: UIButton? = nil
    var isMuted = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        setupDefaultR5VideoViewController()
        
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
        self.subscribeStream?.client = self;
        
        currentView?.attach(subscribeStream)
        
        self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String)
        
        let screenSize = UIScreen.main.bounds.size
        toggleBtn = UIButton(frame: CGRect(x: 0, y: screenSize.height - 38, width: screenSize.width, height: 34))
        toggleBtn?.backgroundColor = UIColor.darkGray
        toggleBtn?.setTitle("Toggle Mute Audio", for: UIControl.State.normal)
        view.addSubview(toggleBtn!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleMute))
        toggleBtn?.addGestureRecognizer(tap)

    }
    
    @objc func toggleMute () {
        isMuted = !isMuted
        self.subscribeStream?.audioController.volume = isMuted ? 0 : 1
    }
    
    func updateOrientation(value: Int) {
        
        if current_rotation == value {
            return
        }
        
        current_rotation = value
        currentView?.view.layer.transform = CATransform3DMakeRotation(CGFloat(value), 0.0, 0.0, 0.0);
        
    }
    
    @objc func onMetaData(data : String) {
        
        let props = data.characters.split(separator: ";").map(String.init)
        props.forEach { (value: String) in
            let kv = value.characters.split(separator: "=").map(String.init)
            if (kv[0] == "orientation") {
                updateOrientation(value: Int(kv[1])!)
            }
        }
        
    }
    
    override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        super.onR5StreamStatus(stream, withStatus: statusCode, withMessage: msg)

        if( Int(statusCode) == Int(r5_status_start_streaming.rawValue) ){
            
            let session : AVAudioSession = AVAudioSession.sharedInstance()
            let cat = session.category
            let opt = session.categoryOptions
            
            let s =  String(format: "AV: %@ (%d)",  cat.rawValue, opt.rawValue)
            ALToastView.toast(in: self.view, withText:s)
            
//            self.subscribeStream?.setFrameListener({data, width, height in
//                uncomment for frameListener stress testing
//            })
        }
    }
    
}
