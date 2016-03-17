//
//  DateNodeCollectionViewItem.swift
//  Filament
//
//  Created by Chris Beeson on 6/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

public class DateNodeCollectionViewItem : NSCollectionViewItem, NSPopoverDelegate, SequencePresenterDelegate, DateTimePickerViewDelegate {
    
    @IBOutlet weak var month: NSTextField!
    @IBOutlet weak var day: NSTextField!
    @IBOutlet weak var dayString: NSTextField!
    @IBOutlet weak var time: NSTextField!
    @IBOutlet weak var circleView: EmptyNodeView!
    @IBOutlet weak var transitionView: TransitionNodeView!
    
    var sequencePresenter: SequencePresenter?
    var popover: NSPopover?
    var dateTimePickerViewController : DateTimePickerViewController?
    
    override public func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    override public func viewWillAppear() {
        super.viewWillAppear()

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
                dateTimePickerViewController!.delegate = self
            }
            popover!.contentViewController = dateTimePickerViewController
        }
        
        if sequencePresenter!.date != nil {
            dateTimePickerViewController!.date = sequencePresenter!.date!
        }
        
        popover?.showRelativeToRect(self.dayString!.frame, ofView: self.view, preferredEdge:.MinX )
    }
    
    public func updateView() {
        
        self.view.alphaValue = self.sequencePresenter?.currentState == .Completed ? 0.5 : 1.0
        
        let hidden = (sequencePresenter!.date == nil) ? true : false
        month.hidden = hidden
        day.hidden = hidden
        dayString.hidden = hidden
        time.hidden = hidden
        transitionView.hidden = !hidden
        circleView.hidden = !hidden
        
        let date = (sequencePresenter!.date != nil) ? sequencePresenter!.date! : NSDate()
        
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM"
            month.stringValue = dateFormatter.stringFromDate(date).capitalizedString
            dateFormatter.dateFormat = "EEE"
            dayString.stringValue = dateFormatter.stringFromDate(date).capitalizedString
            day.stringValue = String(date.day())
            dateFormatter.dateFormat = "HH:mm"
            time.objectValue = dateFormatter.stringFromDate(date)
    }
    
    
    // MARK: DateTimePicker delegate
    
    public func dateTimePickerDidChangeDate(date:NSDate?) {
        self.sequencePresenter!.setDate(date, isStartDate:true)
        updateView()
    }
}