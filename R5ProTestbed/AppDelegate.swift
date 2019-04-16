//
//  AppDelegate.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/16/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var flushBufferDialog: UIAlertController?
    var requiresFlushBufferDialog: Bool? = false


    private func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        

        //NSLog(Testbed.sharedInstance.testWithId("publish")!.description)
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NotificationCenter.default.addObserver(self, selector: #selector(onBufferFlushStart(_:)), name: Notification.Name(rawValue: "BufferFlushStart"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onBufferFlushEmpty(_:)), name: Notification.Name(rawValue: "BufferFlushComplete"), object: nil)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func showFlushBufferDialog() {
        if (requiresFlushBufferDialog)! {
            let alert = UIAlertController(title: "Red5 Pro SDK", message: "Publisher Is Finishing Broadcast.\r\nPlease wait to start another broadcast.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                self.flushBufferDialog = nil
            }))
            self.window!.rootViewController?.present(alert, animated: true, completion:nil)
            flushBufferDialog = alert
        }
    }
    
    @objc func onBufferFlushStart(_ notification:Notification) {
        // TODO: Start 500 ms timer to display process of flushing buffer from a finished broadcast.
        requiresFlushBufferDialog = true
        let deadlineTime = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.showFlushBufferDialog()
        }
    }
    
    @objc func onBufferFlushEmpty(_ notification:Notification) {
        // TODO: Remove any process display from `flush_start`.
        requiresFlushBufferDialog = false
        if (flushBufferDialog != nil) {
            flushBufferDialog?.dismiss(animated: false, completion: {
                self.flushBufferDialog = nil;
            });
        }
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

}

