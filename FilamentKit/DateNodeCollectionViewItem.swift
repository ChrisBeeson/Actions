//
//  DateNodeCollectionViewItem.swift
//  Filament
//
//  Created by Chris Beeson on 6/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class DateNodeCollectionViewItem : NSCollectionViewItem, NSPopoverDelegate, SequencePresenterDelegate {
    
    @IBOutlet weak var month: NSTextField!
    @IBOutlet weak var day: NSTextField!
    @IBOutlet weak var dayString: NSTextField!
    @IBOutlet weak var time: NSTextField!
    
    var sequencePresenter: SequencePresenter?
    var popover: NSPopover?
    var dateTimePickerViewController : DateTimePickerViewController?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func mouseDown(theEvent: NSEvent) {
        
        if popover == nil {
            popover = NSPopover()
            popover!.animates = true
            popover!.behavior = .Transient
            popover!.appearance = NSAppearance(named: NSAppearanceNameAqua)
            popover!.delegate = self
            
            if dateTimePickerViewController  == nil {
                dateTimePickerViewController  = DateTimePickerViewController(nibName:"DateTimePickerViewController", bundle:NSBundle(identifier:"com.andris.FilamentKit"))
            }
            popover!.contentViewController = dateTimePickerViewController
        }
        
        popover?.showRelativeToRect(self.dayString!.frame, ofView: self.view, preferredEdge:.MinX )
    }
    
    public func popoverDidClose(notification: NSNotification) {
        
        self.sequencePresenter!.setDate(self.dateTimePickerViewController!.date!, isStartDate:true)
    }
}