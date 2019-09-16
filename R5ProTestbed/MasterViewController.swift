//
//  MasterViewController.swift
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

class MasterViewController: UITableViewController,UINavigationControllerDelegate {

    var detailViewController: DetailViewController? = nil
   
    var isBlockOnAccessGrant: Bool = false;
    
    let objects = [
        [
            ["Name": "Home", "class": Home.self],
            ["Name": "Publish", "class": PublishTest.self]
        ],
        [
            ["Name": "Adaptive Bitrate", "class": Home.self]
        ]
    ]
    
    open override var shouldAutorotate:Bool {
        get {
            return true
        }
    }
    
    open override var supportedInterfaceOrientations:UIInterfaceOrientationMask {
        get {
            return [UIInterfaceOrientationMask.all]
        }
    }
    
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }


    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let t = Testbed.sharedInstance
        let d = Testbed.dictionary
        NSLog((Testbed.testAtIndex(index: 0)?.description)!)
        
        self.splitViewController!.preferredPrimaryColumnWidthFraction = 0.2
        self.view.autoresizesSubviews = true
        self.splitViewController!.preferredDisplayMode = UISplitViewController.DisplayMode.allVisible
        self.navigationController?.delegate = self

        // Do any additional setup after loading the view, typically from a nib.
       // self.navigationItem.leftBarButtonItem = self.editButtonItem()

        //let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        //self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == .notDetermined {
            
            self.isBlockOnAccessGrant = true
            
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (videoGranted: Bool) in
                
                    AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (audioGranted: Bool) in
                        
                            self.isBlockOnAccessGrant = false
                
                    })
                
            })
        }

    }
    
    @objc func appMovedToBackground() {
        
        if (!self.isBlockOnAccessGrant && (detailViewController == nil || (detailViewController?.shouldClose)!)) {
            let _ = navigationController?.popViewController(animated: false)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        //self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.isBlockOnAccessGrant = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
              
                let object = Testbed.testAtIndex(index: indexPath.row)
                detailViewController = ((segue.destination as! UINavigationController).topViewController as! DetailViewController)
                detailViewController!.detailItem = object
                detailViewController!.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                detailViewController!.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Testbed.sections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Testbed.rowsInSection()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        let description = (Testbed.testAtIndex(index: indexPath.row)?.value(forKey: "name") as! String).description
        cell.textLabel!.text = description
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }

}

