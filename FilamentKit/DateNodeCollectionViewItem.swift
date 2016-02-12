//
//  DateNodeCollectionViewItem.swift
//  Filament
//
//  Created by Chris Beeson on 6/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import MLCalendarView

public class DateNodeCollectionViewItem : NSCollectionViewItem, MLCalendarViewDelegate {
    
    @IBOutlet weak var month: NSTextField!
    @IBOutlet weak var day: NSTextField!
    @IBOutlet weak var dayString: NSTextField!
    @IBOutlet weak var time: NSTextField!
    
   
    var popover: NSPopover?
    var calView: MLCalendarView?
    
    /*
    required public init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
   */
    
    override public func mouseDown(theEvent: NSEvent) {
        
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
        
        popover?.showRelativeToRect(self.dayString!.frame, ofView: self.view, preferredEdge:.MinX )
    }
    

    
    
    public func didSelectDate(selectedDate: NSDate!) {
    }
    
    

    
}
