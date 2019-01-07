//
//  BandwidthDetectionTest.swift
//  R5ProTestbed
//
//  Created by Kyle Kellogg on 7/26/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(BandwidthDetectionDownloadOnlyTest)
class BandwidthDetectionDownloadOnlyTest: BaseTest {
    
    var current_rotation = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let detection = R5BandwidthDetection()
        let config = getConfig()
        
        let minBitrate = Int32(Testbed.getParameter(param: "bitrate") as! Int)
        
        print("Checking download speed... need to be equal to or above \(minBitrate)")
        detection.checkDownloadSpeed(config.host, forSeconds: 2.5, withSuccess: { (Kbps) in
            print("Download (only) speed is \(Kbps)Kbps\n")
            
            if (Kbps >= minBitrate) {
                self.beginStream(config: config)
            } else {
                print("Your download speed was too low to stream!\n")
            }
        }) { (error) in
            print("There was an error checking download speed! \(error?.localizedDescription ?? "Unknown error")\n")
        }
    }
    
    func beginStream(config: R5Configuration) {
        setupDefaultR5VideoViewController()
        
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
        self.subscribeStream?.client = self;
        
        currentView?.attach(subscribeStream)
        
        self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String)
    }
    
    func updateOrientation(value: Int) {
        if current_rotation == value {
            return
        }
        
        current_rotation = value
        currentView?.view.layer.transform = CATransform3DMakeRotation(CGFloat(value), 0.0, 0.0, 0.0);
    }
    
    func onMetaData(data : String) {
        let props = data.characters.split(separator: ";").map(String.init)
        props.forEach { (value: String) in
            let kv = value.characters.split(separator: "=").map(String.init)
            if (kv[0] == "orientation") {
                updateOrientation(value: Int(kv[1])!)
            }
        }
    }
    
}

