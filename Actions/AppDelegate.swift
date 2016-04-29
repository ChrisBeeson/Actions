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

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        NSUserDefaults.standardUserDefaults().registerDefaults(["NSApplicationCrashOnExceptions" : true])
        Fabric.with([Crashlytics.self])
        
        CalendarManager.sharedInstance // TODO: Request 1st time validation at the right time & handle if user denys
        
        NSDocumentController.sharedDocumentController().clearRecentDocuments(self)
        
        
        //   CCNStatusItem.sharedInstance().presentStatusItemWithImage(NSImage(named: "SystemTrayIcon"), contentViewController: nil)
        
        
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    }
    
    
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
         print("Did unhide")
    }
    
    
    //MARK: NSUserNotificationCenterDelegate
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
}

