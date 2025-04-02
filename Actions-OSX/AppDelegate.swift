//
//  AppDelegate.swift
//  Actions
//
//  Created by Chris on 4/09/2015.
//  Copyright (c) 2015 Andris Ltd. All rights reserved.
//

import Cocoa
import Fabric
import Crashlytics
//import Stripe

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        #if OSX_INDEPENDENT
          //  Stripe.setDefaultPublishableKey("pk_test_CrzZEhVuOZXgWJIQyuGHi2qW")
        #endif

        UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions" : true])
       // Fabric.with([Crashlytics.self])
    
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
        
        NSUserNotificationCenter.default.delegate = self
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
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        
        //NotificationCenter.default().postNotificationName("RefreshMainTableView", object: nil)
    }
    
    func applicationDidUnhide(_ notification: Notification) {
    }
    
    
    //MARK: NSUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
}

