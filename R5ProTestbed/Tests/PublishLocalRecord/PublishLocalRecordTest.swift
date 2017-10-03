//
//  PublishLocalRecordTest.swift
//  R5ProTestbed
//
//  Created by David Heimann on 7/31/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(PublishLocalRecordTest)
class PublishLocalRecordTest: PublishTest {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.publishStream!.record(withName: "fileTest")
    }
    
}
