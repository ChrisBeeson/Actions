//
//  WindowController.swift
//  Filament
//
//  Created by Chris Beeson on 1/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
         self.window!.titleVisibility = NSWindowTitleVisibility.Hidden
        
        addObserver(self, forKeyPath: "self.window.firstResponder", options: [.Initial, .Old, .New], context: nil)
        
        let toolBar = TokenAccessoryBarViewController()
        toolBar.layoutAttribute = .Bottom
        self.window!.addTitlebarAccessoryViewController(toolBar)
    }
    

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        

            self.window!.title = "Filament - " + window!.firstResponder.className
    }



    @IBAction func segmentedControlAction(sender: NSSegmentedControl) {
    
    }
}
