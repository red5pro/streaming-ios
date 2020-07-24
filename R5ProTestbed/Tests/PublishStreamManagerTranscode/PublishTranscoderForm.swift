//
//  PublishTranscoderForm.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 19/11/2019.
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

protocol PublishTranscoderFormDelegate: class {
    func onProvisionSubmit(_ controller: PublishTranscoderForm)
}

@objc(PublishTranscoderForm)
class PublishTranscoderForm : UIViewController, UITextFieldDelegate {
    
    weak var delegate : PublishTranscoderFormDelegate?
    weak var activeField : UITextField?
    
    @IBOutlet weak var high_bitrate: UITextField!
    @IBOutlet weak var high_width: UITextField!
    @IBOutlet weak var high_height: UITextField!
    @IBOutlet weak var med_bitrate: UITextField!
    @IBOutlet weak var med_width: UITextField!
    @IBOutlet weak var med_height: UITextField!
    @IBOutlet weak var low_bitrate: UITextField!
    @IBOutlet weak var low_width: UITextField!
    @IBOutlet weak var low_height: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func onSubmit(_ sender: Any) {
        self.delegate?.onProvisionSubmit(self)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!;
    }
    
    init (delegate : PublishTranscoderFormDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        high_bitrate.delegate = self
        high_width.delegate = self
        high_height.delegate = self
        med_bitrate.delegate = self
        med_width.delegate = self
        med_height.delegate = self
        low_bitrate.delegate = self
        low_width.delegate = self
        low_height.delegate = self
        
        high_bitrate.text = String(Testbed.localParameters!["high_bitrate"] as! Int)
        high_width.text = String(Testbed.localParameters!["high_width"] as! Int)
        high_height.text = String(Testbed.localParameters!["high_height"] as! Int)
        med_bitrate.text = String(Testbed.localParameters!["med_bitrate"] as! Int)
        med_width.text = String(Testbed.localParameters!["med_width"] as! Int)
        med_height.text = String(Testbed.localParameters!["med_height"] as! Int)
        low_bitrate.text = String(Testbed.localParameters!["low_bitrate"] as! Int)
        low_width.text = String(Testbed.localParameters!["low_width"] as! Int)
        low_height.text = String(Testbed.localParameters!["low_height"] as! Int)
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
    }
    
    func getHighFormValues () -> (Int, Int, Int) {
        let b : Int! = Int(high_bitrate.text!)
        let w : Int! = Int(high_width.text!)
        let h : Int! = Int(high_height.text!)
        return (b, w, h)
    }
    
    func getMediumFormValues () -> (Int, Int, Int) {
        let b : Int! = Int(med_bitrate.text!)
        let w : Int! = Int(med_width.text!)
        let h : Int! = Int(med_height.text!)
        return (b, w, h)
    }
    
    func getLowFormValues () -> (Int, Int, Int) {
        let b : Int! = Int(low_bitrate.text!)
        let w : Int! = Int(low_width.text!)
        let h : Int! = Int(low_height.text!)
        return (b, w, h)
    }
    
    //function to hide keyboard when Done key tapped for textField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func getKeyboardHeight (notification: NSNotification) -> CGFloat {
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        return keyboardSize!.height
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let is_low_editing = low_bitrate.isEditing || low_width.isEditing || low_height.isEditing
        if is_low_editing {
            self.view.window?.frame.origin.y = -1.0 * getKeyboardHeight(notification: notification)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.window?.frame.origin.y != 0 {
            self.view.window?.frame.origin.y += getKeyboardHeight(notification: notification)
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
}
