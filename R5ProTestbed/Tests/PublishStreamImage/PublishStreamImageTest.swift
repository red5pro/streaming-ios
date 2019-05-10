//
//  PublishStreamImageTest.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/17/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(PublishStreamImageTest)
class PublishStreamImageTest: BaseTest {

    var uiv : UIImageView? = nil
    
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
        // show preview and debug info
        
        self.currentView!.attach(publishStream!)
        
        
        self.publishStream!.publish(Testbed.getParameter(param: "stream1") as! String, type: R5RecordTypeLive)
        
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(recognizer:)))

        self.view.addGestureRecognizer(tap)

        
        uiv = UIImageView(frame: CGRect(x: 0, y: self.view.frame.height-200, width: 300, height: 200))
        uiv!.contentMode = UIView.ContentMode.scaleAspectFit
        self.view.addSubview(uiv!);
        
    }

    @objc func handleSingleTap(recognizer : UITapGestureRecognizer) {

        
        //uiv!.image = self.publishStream?.getStreamImage();
        
        let image = self.publishStream?.getImage()
        if(image == nil){
            NSLog("no image available yet")
            return;
        }
        let imageData = (image)!.jpegData(compressionQuality: 1.0)
        
        if((imageData) != nil){
            NSLog("Got the image data!")
        }else{
            NSLog("Failed to get image data!")
            return;
        }
        
        let imagePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/screencap.png"
        let path = URL(fileURLWithPath: imagePath)
        try! imageData?.write(to: path, options: Data.WritingOptions.atomic)
        
        
        let uim = UIImage.init(contentsOfFile: imagePath)
        uiv!.image = uim;

   
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
