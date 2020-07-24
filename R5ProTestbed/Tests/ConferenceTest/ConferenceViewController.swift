//
//  ConferenceViewController.swift
//  R5ProTestbed
//
//  Created by David Heimann on 5/11/20.
//  Copyright © 2015 Infrared5, Inc. All rights reserved.
// 
//  The accompanying code comprising examples for use solely in conjunction with Red5 Pro (the "Example Code") 
//  is  licensed  to  you  by  Infrared5  Inc.  in  consideration  of  your  agreement  to  the  following  
//  license terms  and  conditions.  Access,  use,  modification,  or  redistribution  of  the  accompanying  
//  code  constitutes your acceptance of the following license terms and conditions.
//  
//  Permission is hereby granted, free of charge, to you to use the Example Code and associated documentation 
//  files (collectively, the "Software") without restriction, including without limitation the rights to use, 
//  copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit 
//  persons to whom the Software is furnished to do so, subject to the following conditions:
//  
//  The Software shall be used solely in conjunction with Red5 Pro. Red5 Pro is licensed under a separate end 
//  user  license  agreement  (the  "EULA"),  which  must  be  executed  with  Infrared5,  Inc.   
//  An  example  of  the EULA can be found on our website at: https://account.red5pro.com/assets/LICENSE.txt.
// 
//  The above copyright notice and this license shall be included in all copies or portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,  INCLUDING  BUT  
//  NOT  LIMITED  TO  THE  WARRANTIES  OF  MERCHANTABILITY, FITNESS  FOR  A  PARTICULAR  PURPOSE  AND  
//  NONINFRINGEMENT.   IN  NO  EVENT  SHALL INFRARED5, INC. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
//  WHETHER IN  AN  ACTION  OF  CONTRACT,  TORT  OR  OTHERWISE,  ARISING  FROM,  OUT  OF  OR  IN CONNECTION 
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import Foundation

protocol ConferenceViewControllerDelegate: class {
    func connectTrigger()
    func videoMuteTrigger()
    func audioMuteTrigger()
}

@objc(ConferenceViewController)
class ConferenceViewController : UIViewController, UITextFieldDelegate {
    
    var delegate : ConferenceViewControllerDelegate? = nil
    
    @IBOutlet weak var nameView : UIView!
    @IBOutlet weak var muteView : UIView!
    
    @IBOutlet weak var streamNameField : UITextField!
    @IBOutlet weak var roomNameField : UITextField!
    @IBOutlet weak var videoMuteText : UILabel!
    @IBOutlet weak var videoMuteButton : UIView!
    @IBOutlet weak var audioMuteText : UILabel!
    @IBOutlet weak var audioMuteButton : UIView!
    @IBOutlet weak var clearSwitch : UISwitch!
    
    var videoOn = true
    var audioOn = true
    var clearOn = false
    
    @IBAction func connectTouch(_ sender: Any) {
        nameView.alpha = 0.0
        toggleMuteVisibility()
        if(clearSwitch.isOn){
            clearOn = true
            clearSwitch.setOn(false, animated: false)
        }
        delegate?.connectTrigger()
    }
    
    @IBAction func videoMuteTap(_ sender: Any) {
         if(videoOn){
            videoMuteButton.backgroundColor = UIColor.red
            videoMuteText.text = "Video: Off"
             videoOn = false
         } else {
            videoMuteButton.backgroundColor = UIColor.green
            videoMuteText.text = "Video: On"
             videoOn = true
         }
        delegate?.videoMuteTrigger()
    }
    
    @IBAction func audioMuteTap(_ sender: Any) {
         if(audioOn){
            audioMuteButton.backgroundColor = UIColor.red
            audioMuteText.text = "Audio: Off"
             audioOn = false
         } else {
            audioMuteButton.backgroundColor = UIColor.green
            audioMuteText.text = "Audio: On"
             audioOn = true
         }
        delegate?.audioMuteTrigger()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        streamNameField.text = String(format: "ios-%04d", Int.random(in: 0..<10000))
        roomNameField.text = "red5pro"
        
        nameView.backgroundColor = UIColor(white: 1, alpha: 0.0)
        muteView.backgroundColor = UIColor(white: 1, alpha: 0.0)
    }
    
    func toggleMuteVisibility() {
        if(muteView.alpha < 0.5) {
            muteView.alpha = 1.0
        } else {
            muteView.alpha = 0.0
        }
    }
}
