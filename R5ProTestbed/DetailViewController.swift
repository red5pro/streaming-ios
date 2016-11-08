//
//  DetailViewController.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/16/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

class DetailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var hostText: UITextField!
    @IBOutlet weak var stream1Text: UITextField!
    @IBOutlet weak var stream2Text: UITextField!
    @IBOutlet weak var debugSwitch: UISwitch!
    @IBOutlet weak var videoSwitch: UISwitch!
    @IBOutlet weak var audioSwitch: UISwitch!
    
    var r5ViewController : BaseTest? = nil
   
    var detailItem: NSDictionary? {
        didSet {
            // Update the view.
           // self.configureView()
        }
    }
    
    @IBAction func onStream1NameChange(sender: AnyObject) {
        Testbed.setStream1Name(stream1Text.text!)
    }
    @IBAction func onStream2NameChange(sender: AnyObject) {
        Testbed.setStream2Name(stream2Text.text!)
    }
    @IBAction func onStreamNameSwap(sender: AnyObject) {
        Testbed.setStream1Name(stream2Text.text!)
        Testbed.setStream2Name(stream1Text.text!)
        stream1Text.text = Testbed.parameters!["stream1"] as? String
        stream2Text.text = Testbed.parameters!["stream2"] as? String
    }
    @IBAction func onHostChange(sender: AnyObject) {
        Testbed.setHost(hostText.text!)
    }
    @IBAction func onDebugChange( sender: AnyObject) {
        Testbed.setDebug(debugSwitch.on)
    }
    @IBAction func onVideoChange( sender: AnyObject) {
        Testbed.setVideo(videoSwitch.on)
    }
    @IBAction func onAudioChange( sender: AnyObject) {
        Testbed.setAudio(audioSwitch.on)
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        
        
        hostText.text = Testbed.parameters!["host"] as? String
        stream1Text.text = Testbed.parameters!["stream1"] as? String
        stream2Text.text = Testbed.parameters!["stream2"] as? String
        
        hostText.delegate = self
        stream1Text.delegate = self
        stream2Text.delegate = self
        
        debugSwitch.setOn((Testbed.parameters!["debug_view"] as? Bool)!, animated: false)
        videoSwitch.setOn((Testbed.parameters!["video_on"] as? Bool)!, animated: false)
        audioSwitch.setOn((Testbed.parameters!["audio_on"] as? Bool)!, animated: false)
        
        if(self.detailItem != nil){
            
            if(self.detailItem!["description"] != nil){

                let navButton = UIBarButtonItem(title: "Info", style: UIBarButtonItemStyle.Plain, target: self, action: "showInfo")
                navButton.imageInsets = UIEdgeInsetsMake(10, 10, 10, 10);

                navigationItem.rightBarButtonItem =    navButton
            }
            
            Testbed.setLocalOverrides(self.detailItem!["LocalProperties"] as? NSMutableDictionary)
            
            
            let className = self.detailItem!["class"] as! String
            let mClass = NSClassFromString(className) as! BaseTest.Type;
           
            //only add this view if it isn't HOME
            if(!(mClass is Home.Type)){
                r5ViewController  = mClass.init()

                self.addChildViewController(r5ViewController!)
                self.view.addSubview(r5ViewController!.view)
    
                r5ViewController!.view.autoresizesSubviews = true
                r5ViewController!.view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth];
            }

        }

    
    }
    
    func showInfo(){
        let alert = UIAlertView()
        alert.title = "Info"
        alert.message = self.detailItem!["description"] as? String
        alert.addButtonWithTitle("OK")
        alert.show()
        
      
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    
    override func viewWillDisappear(animated: Bool) {
     
       closeCurrentTest()
    }
    
    func closeCurrentTest(){
        
        if(r5ViewController != nil){
            r5ViewController!.closeTest()
        }
        r5ViewController = nil
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        self.view.autoresizesSubviews = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

