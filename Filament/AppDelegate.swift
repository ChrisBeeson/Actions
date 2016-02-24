//
//  AppDelegate.swift
//  Filament
//
//  Created by Chris on 4/09/2015.
//  Copyright (c) 2015 Andris Ltd. All rights reserved.
//

import Cocoa
//import CCNStatusItem
import FilamentKit
import Fabric
import Crashlytics

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        NSUserDefaults.standardUserDefaults().registerDefaults(["NSApplicationCrashOnExceptions" : true])
        
           Fabric.with([Crashlytics.self])
        
        //   CCNStatusItem.sharedInstance().presentStatusItemWithImage(NSImage(named: "SystemTrayIcon"), contentViewController: nil)
    }
    
    
    func applicationWillTerminate(aNotification: NSNotification) {
      
        FilamentDocumentsManager.sharedManager.saveAllDocuments()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}

