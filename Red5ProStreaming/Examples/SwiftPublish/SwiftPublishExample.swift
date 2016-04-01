//
//  SwiftPublishExample.swift
//  Red5ProStreaming
//
//  Created by Andy Zupko on 11/23/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import R5Streaming

@objc class PublishSwiftViewController: BaseExample {
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        AVAudioSession.sharedInstance().requestRecordPermission { (gotPerm: Bool) -> Void in
            NSLog("got permission");
        };
        
        r5_set_log_level((Int32)(r5_log_level_debug.rawValue))
        
        let path = NSBundle.mainBundle().pathForResource("connection", ofType: "plist")
        
        let dict : NSDictionary? =  NSDictionary(contentsOfFile: path!)
        
        //Setup a configuration object for our connection
        let config = R5Configuration()
        config.host = dict!["domain"] as? String
        config.contextName = dict!["context"] as? String
        config.port = (dict!["port"] as? NSNumber)!.intValue
        config.`protocol` = 1;
        config.buffer_time = 1;

        // Set up the connection and stream
        let connection = R5Connection(config: config)
        publish = R5Stream(connection: connection)
        publish.delegate = self
        
        //Attach video to stream
        let videoDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).last as? AVCaptureDevice
        
        let camera = R5Camera(device: videoDevice, andBitRate: 512)
        camera.width = 640
        camera.height = 480
        camera.orientation = 90
        publish.attachVideo(camera)
        
        // Attach the audio from microphone to stream
        let audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        let microphone = R5Microphone(device: audioDevice)
        microphone.bitrate = 32

        publish.attachAudio(microphone)
        
        //Setup the r5View from BaseExample
        setupDefaultR5ViewController()
        
        //attach the stream!
        r5View.attachStream(publish)
        
        // Start streaming
        publish.publish(getStreamName(PUBLISH), type: R5RecordTypeLive)
        
    }
    
    
    override func onR5StreamStatus(stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        print("StatusCode = \(statusCode) with message \"\(msg)\"")
    }
}

