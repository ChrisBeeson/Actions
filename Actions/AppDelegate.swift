//
//  AppDelegate.swift
//  Actions
//
//  Created by Chris on 4/09/2015.
//  Copyright (c) 2015 Andris Ltd. All rights reserved.
//

import Cocoa
//import CCNStatusItem
import ActionsKit
import Fabric
import Crashlytics
import DateTools
import Parse

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        NSUserDefaults.standardUserDefaults().registerDefaults(["NSApplicationCrashOnExceptions" : true])
        Fabric.with([Crashlytics.self])
    
        AppConfiguration.sharedConfiguration.applicationLaunched()
        
        
        
        // User Notifications
        /*
        let userNotificationTypes: NSUserNotificationType = [.Alert, .Badge, .Sound]
        let settings = NSUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        */
                
        //[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        //[[GAI sharedInstance] trackerWithTrackingId:@"UA-62707376-1"];
        
       
        
        //NSDocumentController.sharedDocumentController().clearRecentDocuments(self)
        //CCNStatusItem.sharedInstance().presentStatusItemWithImage(NSImage(named: "SystemTrayIcon"), contentViewController: nil)
        
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    }
    
    /*
    func application(application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
 */
    
    func applicationWillTerminate(aNotification: NSNotification) {
      
        ActionsDocumentManager.sharedManager.saveAllDocuments()
        AppConfiguration.sharedConfiguration.saveContext()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        
        //NSNotificationCenter.defaultCenter().postNotificationName("RefreshMainTableView", object: nil)
    }
    
    func applicationDidUnhide(notification: NSNotification) {
    }
    
    
    //MARK: NSUserNotificationCenterDelegate
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
}

