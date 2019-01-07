//
//  BandwidthDetectionTest.swift
//  R5ProTestbed
//
//  Created by Kyle Kellogg on 7/26/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(BandwidthDetectionUploadOnlyTest)
class BandwidthDetectionUploadOnlyTest: BaseTest {
    
    var current_rotation = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in

        };
        
        let detection = R5BandwidthDetection()
        let config = getConfig()
        
        let minBitrate = Int32(Testbed.getParameter(param: "bitrate") as! Int)
        
        print("Checking upload speed... need to be equal to or above \(minBitrate)")
        detection.checkUploadSpeed(config.host, forSeconds: 2.5, withSuccess: { (Kbps) in
            print("Upload (only) speed is \(Kbps)Kbps\n")
            
            if (Kbps >= minBitrate) {
                self.beginStream(config: config)
            } else {
                print("Your upload speed was too low to stream!\n")
            }
        }) { (error) in
            print("There was an error checking upload speed! \(error?.localizedDescription ?? "Unknown error")\n")
        }
    }
    
    func beginStream(config: R5Configuration) {
        setupDefaultR5VideoViewController()
        
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        
        setupPublisher(connection: connection!)
        // show preview and debug info
        // self.publishStream?.getVideoSource().fps = 2;
        self.currentView!.attach(publishStream!)
        
        self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: R5RecordTypeLive)
    }
    
}

