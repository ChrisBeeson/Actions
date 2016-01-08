//
//  DateNodeView.swift
//  Filament
//
//  Created by Chris Beeson on 6/01/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import MLCalendarView

class DateNodeView: NSView, MLCalendarViewDelegate {
    
    @IBOutlet weak var view: NSView!
    @IBOutlet weak var month: NSTextField!
    @IBOutlet weak var day: NSTextField!
    @IBOutlet weak var dayString: NSTextField!
    @IBOutlet weak var time: NSTextField!
    
    var popover: NSPopover?
    var calView: MLCalendarView?
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    
    init() {
        super.init(frame: NSRect(x: 0.0, y: 0.0, width: 53, height: 42))
        
        let frameworkBundle = NSBundle(forClass:object_getClass(self))
        assert(frameworkBundle.loadNibNamed("DateNodeView", owner: self, topLevelObjects: nil))
        self.addSubview(view)
    }
    
    override func mouseDown(theEvent: NSEvent) {
        
        // display calendar popup
        
        if popover == nil {
            popover = NSPopover()
            popover!.animates = true
            popover!.behavior = .Transient
            popover!.appearance = NSAppearance(named: NSAppearanceNameAqua)
            
            if calView == nil {
                calView = MLCalendarView()
                calView!.delegate = self
            }
            
            popover!.contentViewController = calView
        }
        
        popover?.showRelativeToRect(self.frame, ofView: self, preferredEdge: .MinY)
    }
    
    internal func didSelectDate(selectedDate: NSDate!) {
        Swift.print("Date selected")
    }
}

