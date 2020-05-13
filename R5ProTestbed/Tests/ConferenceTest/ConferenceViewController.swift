//
//  ConferenceViewController.swift
//  R5ProTestbed
//
//  Created by David Heimann on 5/11/20.
//  Copyright © 2020 Infrared5. All rights reserved.
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
    
    var videoOn = true
    var audioOn = true
    
    @IBAction func connectTouch(_ sender: Any) {
        
        nameView.alpha = 0.0
        toggleMuteVisibility()
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
    
    func toggleMuteVisibility() {
        if(muteView.alpha < 0.5) {
            muteView.alpha = 1.0
        } else {
            muteView.alpha = 0.0
        }
    }
}
