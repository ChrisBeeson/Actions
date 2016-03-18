//
//  WindowController.swift
//  Filament
//
//  Created by Chris Beeson on 1/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa
import FilamentKit

class MainWindowController: NSWindowController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addObserver(self, forKeyPath: "self.window.firstResponder", options: [.Initial, .Old, .New], context: nil)
    }
    
    
    override func  windowDidLoad() {
        super.windowDidLoad()
         self.window!.titleVisibility = NSWindowTitleVisibility.Hidden
        
        NSNotificationCenter.defaultCenter().addObserverForName("DisplayCannotAccessCalendarAlert", object: nil, queue: nil) { (notification) -> Void in
            
            let alert = NSAlert()
            alert.informativeText = "MAINWINDOW_CALENDAR_UNAUTHORIZED_BODY".localized
            alert.messageText = "MAINWINDOW_CALENDAR_UNAUTHORIZED_TITLE".localized
            alert.showsHelp = false
            alert.addButtonWithTitle("MAINWINDOW_CALENDAR_UNAUTHORIZED_OK".localized)
            alert.runModal()
        }
    }
        
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        self.window!.title = "Filament - " + window!.firstResponder.className
    }
    
    
    @IBAction func segmentedControlAction(sender: NSSegmentedControl) {
        (self.contentViewController as! FilamentsTableViewController).setTableViewFilter(DocumentFilterType(rawValue: sender.selectedSegment)!)
    }
    

}
