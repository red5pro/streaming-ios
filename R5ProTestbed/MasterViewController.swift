//
//  MasterViewController.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/16/15.
//  Copyright © 2015 Infrared5. All rights reserved.
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
        self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
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
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio) == .notDetermined {
            
            self.isBlockOnAccessGrant = true
            
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (videoGranted: Bool) in
                
                    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { (audioGranted: Bool) in
                        
                            self.isBlockOnAccessGrant = false
                
                    })
                
            })
        }

    }
    
    func appMovedToBackground() {
        
        if !self.isBlockOnAccessGrant {
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
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
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

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }

}

