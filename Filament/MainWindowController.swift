//
//  WindowController.swift
//  Filament
//
//  Created by Chris Beeson on 1/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.window!.titleVisibility = NSWindowTitleVisibility.Hidden
    }
    
    
    @IBAction func segmentedControlAction(sender: NSSegmentedControl) {
        
        print("Segmented Control Changed")
    }
    
}
