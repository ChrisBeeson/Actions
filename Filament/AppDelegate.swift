//
//  AppDelegate.swift
//  Filament
//
//  Created by Chris on 4/09/2015.
//  Copyright (c) 2015 Andris Ltd. All rights reserved.
//

import Cocoa
import CCNStatusItem

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
     //   let contentView = ViewController().
        CCNStatusItem.sharedInstance().presentStatusItemWithImage(NSImage(named: "SystemTrayIcon"), contentViewController: nil)
        
        
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

