//
//  MasterViewController.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/16/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
   
    
    let objects = [
        [
            ["Name": "Home", "class": Home.self],
            ["Name": "Publish", "class": PublishTest.self]
        ],
        [
            ["Name": "Adaptive Bitrate", "class": Home.self]
        ]
    ]
    


    override func viewDidLoad() {
        super.viewDidLoad()
        self.splitViewController!.preferredPrimaryColumnWidthFraction = 0.2
        self.view.autoresizesSubviews = true
        self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible

        // Do any additional setup after loading the view, typically from a nib.
       // self.navigationItem.leftBarButtonItem = self.editButtonItem()

        //let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        //self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        //self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
              
                let object = Testbed.testAtIndex(indexPath.row)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return Testbed.sections()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Testbed.rowsInSection()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)


        cell.textLabel!.text = Testbed.testAtIndex(indexPath.row)?.valueForKey("name")?.description
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
           }


}

