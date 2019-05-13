//
//  PublishCustomSourceTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 5/9/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(PublishCustomSourceTest)
class PublishCustomSourceTest : BaseTest {

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated);
        
        setupDefaultR5VideoViewController()
        
        // Set up the configuration
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        
        
        self.publishStream = R5Stream(connection: connection)
        self.publishStream!.delegate = self
        
        
        // Attach the custom source to the stream
        let videoSource: CustomVideoSource = CustomVideoSource();
        self.publishStream!.attachVideo(videoSource);
        
            
        if(Testbed.getParameter(param: "audio_on") as! Bool){
            // Attach the audio from microphone to stream
            let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
            let microphone = R5Microphone(device: audioDevice)
            microphone?.bitrate = 32
            microphone?.device = audioDevice;
            NSLog("Got device %@", String(describing: audioDevice?.localizedName))
            self.publishStream!.attachAudio(microphone)
        }
        
        
        // show preview and debug info
        // self.publishStream?.getVideoSource().fps = 2;
        self.currentView!.attach(publishStream!)
        
        
        self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: R5RecordTypeLive)
    }
    
    override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        super.onR5StreamStatus(stream, withStatus: statusCode, withMessage: msg)
        if (Int(statusCode) == Int(r5_status_buffer_flush_start.rawValue)) {
            NotificationCenter.default.post(Notification(name: Notification.Name("BufferFlushStart")))
        }
        else if (Int(statusCode) == Int(r5_status_buffer_flush_empty.rawValue)) {
            NotificationCenter.default.post(Notification(name: Notification.Name("BufferFlushComplete")))
        }
    }
}
