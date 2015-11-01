//
//  WindowController.swift
//  Filament
//
//  Created by Chris Beeson on 1/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
         self.window!.titleVisibility = NSWindowTitleVisibility.Hidden
    }
    
    }
