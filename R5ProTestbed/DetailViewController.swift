//
//  DetailViewController.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/16/15.
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

import UIKit
import R5Streaming

class DetailViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var hostText: UITextField!
    @IBOutlet weak var portText: UITextField!
    @IBOutlet weak var stream1Text: UITextField!
    @IBOutlet weak var stream2Text: UITextField!
    @IBOutlet weak var debugSwitch: UISwitch!
    @IBOutlet weak var videoSwitch: UISwitch!
    @IBOutlet weak var audioSwitch: UISwitch!
    @IBOutlet weak var hwAccelSwitch: UISwitch!
    @IBOutlet weak var recordSwitch: UISwitch!
    @IBOutlet weak var appendSwitch: UISwitch!

    @IBOutlet weak var licenseText: UILabel!
    @IBOutlet weak var licenseButton: UIButton!

    var r5ViewController : BaseTest? = nil

    var detailItem: NSDictionary? {
        didSet {
            // Update the view.
           // self.configureView()
        }
    }

    @IBAction func onChangeLicense(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Red5 Pro SDK", message: "Enter In Your SDK License", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) in
            let field = alert.textFields?[0]
            let entry = field?.text
            if (entry != "") {
                Testbed.setLicenseKey(value: entry!)
                self.licenseText.text = entry
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler:nil))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter SDK License:"
            textField.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        })
        self.present(alert, animated: true, completion:nil);
    }

    @IBAction func onStream1NameChange(_ sender: AnyObject) {
        Testbed.setStream1Name(name: stream1Text.text!)
    }
    @IBAction func onStream2NameChange(_ sender: AnyObject) {
        Testbed.setStream2Name(name: stream2Text.text!)
    }
    @IBAction func onStreamNameSwap(_ sender: AnyObject) {
        Testbed.setStream1Name(name: stream2Text.text!)
        Testbed.setStream2Name(name: stream1Text.text!)
        stream1Text.text = Testbed.parameters!["stream1"] as? String
        stream2Text.text = Testbed.parameters!["stream2"] as? String
    }

    @IBAction func onHostChange(_ sender: AnyObject) {
        Testbed.setHost(ip: hostText.text!)
    }
    @IBAction func onPortChange(_ sender: Any) {
        Testbed.setServerPort(port: portText.text!)
    }
    @IBAction func onDebugChange(_ sender: AnyObject) {
        Testbed.setDebug(on: debugSwitch.isOn)
    }
    @IBAction func onVideoChange(_ sender: AnyObject) {
        Testbed.setVideo(on: videoSwitch.isOn)
    }
    @IBAction func onAudioChange(_ sender: AnyObject) {
        Testbed.setAudio(on: audioSwitch.isOn)
    }
    @IBAction func onHWAccelChange(_ sender: AnyObject) {
        Testbed.setHWAccel(on: hwAccelSwitch.isOn)
    }

    @IBAction func onRecordSwitch(_ sender: Any) {
        Testbed.setRecord(on: recordSwitch.isOn)
        appendSwitch.isEnabled = recordSwitch.isOn
    }
    @IBAction func onAppendSwitch(_ sender: Any) {
        Testbed.setRecordAppend(on: appendSwitch.isOn)
    }

    func configureView() {
        // Update the user interface for the detail item.

        // Access the static shared interface to ensure it's loaded
        _ = Testbed.sharedInstance

        hostText.text = Testbed.parameters!["host"] as? String
//        portText.text = Testbed.parameters!["server_port"] as? String
        stream1Text.text = Testbed.parameters!["stream1"] as? String
        stream2Text.text = Testbed.parameters!["stream2"] as? String

        hostText.delegate = self
//        portText.delegate = self
        stream1Text.delegate = self
        stream2Text.delegate = self

        debugSwitch.setOn((Testbed.parameters!["debug_view"] as? Bool)!, animated: false)
        videoSwitch.setOn((Testbed.parameters!["video_on"] as? Bool)!, animated: false)
        audioSwitch.setOn((Testbed.parameters!["audio_on"] as? Bool)!, animated: false)

        hwAccelSwitch.setOn((Testbed.parameters!["hwaccel_on"] as? Bool)!, animated: false)

        recordSwitch.setOn((Testbed.parameters!["record_on"] as? Bool)!, animated: false)
        appendSwitch.setOn((Testbed.parameters!["append_on"] as? Bool)!, animated: false)
        appendSwitch.isEnabled = (Testbed.parameters!["record_on"] as? Bool)!

        let licenseKey = Testbed.parameters!["license_key"] as? String
        licenseText.text = licenseKey == nil || licenseKey == "" ? "No License Found" : licenseKey;

        if(self.detailItem != nil){

            if(self.detailItem!["description"] != nil){

                let navButton = UIBarButtonItem(title: "Info", style: UIBarButtonItem.Style.plain, target: self, action: #selector(showInfo))
                navButton.imageInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10);

                navigationItem.rightBarButtonItem =    navButton
            }

            Testbed.setLocalOverrides(params: self.detailItem!["LocalProperties"] as? NSMutableDictionary)


            let className = self.detailItem!["class"] as! String
            let mClass = NSClassFromString(className) as! BaseTest.Type;

            //only add this view if it isn't HOME
            if(!(mClass is Home.Type)){
                r5ViewController  = mClass.init()

                self.addChild(r5ViewController!)
                self.view.addSubview(r5ViewController!.view)

                //r5ViewController!.view.autoresizesSubviews = false
                //r5ViewController!.view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth];
            }

        }


    }

    @objc func showInfo(){
        let alert = UIAlertView()
        alert.title = "Info"
        alert.message = self.detailItem!["description"] as? String
        alert.addButton(withTitle: "OK")
        alert.show()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }


    override func viewWillDisappear(_ animated: Bool) {
       closeCurrentTest()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
    }

    func closeCurrentTest(){

        if( r5ViewController != nil ){
            r5ViewController!.closeTest()
            r5ViewController = nil
        }

    }

    var shouldClose:Bool{
        get{
            if(r5ViewController != nil){
                return (r5ViewController?.shouldClose)!
            }
            else{
                return true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        //self.view.autoresizesSubviews = true
        self.navigationController?.delegate = self

        // [TA] Testing RPRO-4691 to allow fro deactivation of record and resume of previous set category.
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
//            try AVAudioSession.sharedInstance().setActive(true)
//        }
//        catch {
//            //
//        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    open override var shouldAutorotate:Bool {
        get {
            return true
        }
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return [UIInterfaceOrientationMask.all]
        }
    }

    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }

}
