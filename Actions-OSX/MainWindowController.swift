//
//  WindowController.swift
//  Actions
//
//  Created by Chris Beeson on 1/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addObserver(self, forKeyPath: "self.window.firstResponder", options: [.initial, .old, .new], context: nil)
    }
    
    override func  windowDidLoad() {
        super.windowDidLoad()
        self.window!.titleVisibility = NSWindowTitleVisibility.hidden
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "DisplayCannotAccessCalendarAlert"), object: nil, queue: nil) { (notification) -> Void in
            let alert = NSAlert()
            alert.informativeText = "MAINWINDOW_CALENDAR_UNAUTHORIZED_BODY".localized
            alert.messageText = "MAINWINDOW_CALENDAR_UNAUTHORIZED_TITLE".localized
            alert.showsHelp = false
            alert.addButton(withTitle: "MAINWINDOW_CALENDAR_UNAUTHORIZED_OK".localized)
            alert.runModal()
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /* fix:
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutableRawPointer) {
        self.window!.title = "Actions - " + (window!.firstResponder?.className)!
    }
    */

    @IBAction func segmentedControlAction(sender: NSSegmentedControl) {
        (self.contentViewController as! MainTableViewController).setTableViewFilter(filter: DocumentFilterType(rawValue: sender.selectedSegment)!)
    }
}
