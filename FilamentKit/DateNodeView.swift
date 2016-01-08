//
//  DateNodeView.swift
//  Filament
//
//  Created by Chris Beeson on 6/01/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class DateNodeView: NSView {
    
    @IBOutlet weak var view: NSView!
    @IBOutlet weak var month: NSTextField!
    @IBOutlet weak var day: NSTextField!
    @IBOutlet weak var dayString: NSTextField!
    @IBOutlet weak var time: NSTextField!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    
    init() {
        super.init(frame: NSRect(x: 0.0, y: 0.0, width: 53, height: 42))
        
        let frameworkBundle = NSBundle(forClass:object_getClass(self))
        assert(frameworkBundle.loadNibNamed("DateNodeView", owner: self, topLevelObjects: nil))
        self.addSubview(view)
    }
}

