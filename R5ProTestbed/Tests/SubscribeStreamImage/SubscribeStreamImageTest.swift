//
//  PublishStreamImageTest.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/17/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeStreamImageTest)
class SubscribeStreamImageTest: BaseTest {
    
    var uiv : UIImageView? = nil
    
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
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SubscribeStreamImageTest.handleSingleTap(recognizer:)))
        
        self.view.addGestureRecognizer(tap)
        
        
        uiv = UIImageView(frame: CGRect(x: 0, y: self.view.frame.height-200, width: 300, height: 200))
        uiv!.contentMode = UIView.ContentMode.scaleAspectFit
        self.view.addSubview(uiv!);
        
    }
    
    @objc func handleSingleTap(recognizer : UITapGestureRecognizer) {
        
        
       let image = self.subscribeStream?.getImage()
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
    
    
}
