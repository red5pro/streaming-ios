//
//  BandwidthDetectionTest.swift
//  R5ProTestbed
//
//  Created by Kyle Kellogg on 7/25/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(BandwidthDetectionTest)
class BandwidthDetectionTest: BaseTest {

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
        
        print("Checking speeds... need to be equal to or above \(minBitrate)")
        detection.checkSpeeds(config.host, forSeconds: 2.5, withSuccess: { (response) in
            let responseDict = response! as NSDictionary
            let download = Int32(responseDict.object(forKey: "download") as! Int)
            let upload = Int32(responseDict.object(forKey: "upload") as! Int)
            print("Download speed is \(download)Kbps\nUpload speed is \(upload)Kbps\n")
            
            if (download >= minBitrate && upload > minBitrate) {
                self.beginStream(config: config)
            } else {
                print("Your bandwidth is too low to stream!\n");
            }
        }) { (error) in
            print("There was an error checking your speeds! \(error?.localizedDescription ?? "Unknown error")")
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

    @objc func onMetaData(data : String) {
        let props = data.characters.split(separator: ";").map(String.init)
        props.forEach { (value: String) in
            let kv = value.characters.split(separator: "=").map(String.init)
            if (kv[0] == "orientation") {
                updateOrientation(value: Int(kv[1])!)
            }
        }
    }

}

