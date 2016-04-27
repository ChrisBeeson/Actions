//
//  DateNodeCollectionViewItem.swift
//  Actions
//
//  Created by Chris Beeson on 6/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

public class DateNodeCollectionViewItem : NSCollectionViewItem, NSPopoverDelegate, SequencePresenterDelegate, DateTimePickerViewDelegate, DragDropCopyPasteItem {
    
    @IBOutlet weak var startDateNilView: NSView!
    @IBOutlet weak var dateNotNilView: NSView!
    @IBOutlet weak var endDateNilView: NSView!
    @IBOutlet weak var dateStackView: NSStackView!
    
    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var dayStringLabel: NSTextField!
    @IBOutlet weak var dateStringLabel: NSTextField!
    
    weak var sequencePresenter: SequencePresenter?
    var displayedPopover: NSPopover?
    var dateFormatter = NSDateFormatter()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func viewWillAppear() {
        super.viewWillAppear()
         updateView()
    }
    
    override public func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
        
        if displayedPopover != nil { return }
        guard sequencePresenter?.currentState != .Completed else {return}
        
        let popover = NSPopover()
        popover.animates = true
        popover.behavior = .Semitransient
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        popover.delegate = self
        
        let dateTimePickerViewController  = DateTimePickerViewController(nibName:"DateTimePickerViewController", bundle:NSBundle(identifier:"com.andris.ActionsKit"))
        dateTimePickerViewController!.delegate = self
        popover.contentViewController = dateTimePickerViewController
        if sequencePresenter!.date != nil {
            dateTimePickerViewController!.date = sequencePresenter!.date!
        }
        
        if sequencePresenter!.timeDirection == TimeDirection.Forward {
           popover.showRelativeToRect(self.view.frame, ofView:self.view.superview!, preferredEdge:.MinX)
        } else {
            popover.showRelativeToRect(self.view.frame, ofView:self.view.superview!, preferredEdge:.MaxX)
        }
        displayedPopover = popover
    }
    
    public func updateView() {
        displayedPopover = nil
        
        let item = self.view.menu?.itemAtIndex(5)
        if sequencePresenter!.timeDirection == .Forward {
            item!.title = "SEQ_DATE_MENU_SET_DATE_STARTTIME".localized
        } else {
             item!.title = "SEQ_DATE_MENU_SET_DATE_ENDTIME".localized
        }
        
        self.view.alphaValue = self.sequencePresenter?.currentState == .Completed ? 0.5 : 1.0
        startDateNilView.hidden = true
        dateNotNilView.hidden = true
        endDateNilView.hidden = true
        
        let hasDate = (sequencePresenter!.date == nil) ? false : true
        let direction = sequencePresenter!.timeDirection
        
        switch (hasDate, direction) {
        case (false, .Forward):
            startDateNilView.animator().hidden = false ; return
        case (false, .Backward):
            endDateNilView.animator().hidden = false ; return
        case (true, .Forward):
            dateNotNilView.hidden = false
            dateStackView.alignment = .Trailing
        case (true, .Backward):
            dateNotNilView.hidden = false
            dateStackView.alignment = .Leading
        }
        
        // Update labels
        
        // Time
        dateFormatter.dateFormat = "HH:mm"
        timeLabel.stringValue = dateFormatter.stringFromDate(sequenceDate)
        
        // Day String
        dateFormatter.dateFormat = "EEE"
        dayStringLabel.stringValue = dateFormatter.stringFromDate(sequenceDate).uppercaseString

        // Date String (eg 20 AUG)
        dateFormatter.dateFormat = "MMM"
        let monthString = dateFormatter.stringFromDate(sequenceDate).uppercaseString
        let day = String(sequenceDate.day())
        dateStringLabel.stringValue = "\(day) \(monthString)"
    }
    
    public var sequenceDate: NSDate {
        var returnDate: NSDate
        if sequencePresenter == nil { return NSDate() }
        returnDate = (sequencePresenter!.date != nil) ? sequencePresenter!.date! : NSDate()
        return returnDate
    }
    
    // MARK: DateTimePicker delegate
    
    public func dateTimePickerDidChangeDate(date:NSDate?) {
        self.sequencePresenter!.setDate(date, direction:self.sequencePresenter!.timeDirection)
        displayedPopover?.performClose(self)
        //  updateView()
    }
    
    public func sequencePresenterDidChangeState(sequencePresenter: SequencePresenter, toState:SequenceState) {
         updateView()
    }
    
    public func sequencePresenterUpdatedDate(sequencePresenter: SequencePresenter) {
        updateView()
        
    }
    
    
    //MARK: Menu
    
    public func clear(event: NSEvent) {
        self.sequencePresenter!.setDate(nil, direction:self.sequencePresenter!.timeDirection)
        displayedPopover = nil
    }
    
    public func copy(event: NSEvent) {
        let pasteboard = NSPasteboard.generalPasteboard()
        pasteboard.clearContents()
        pasteboard.writeObjects([pasteboardItem()])
    }
    
    public func paste(event: NSEvent) {
        let pasteboard = NSPasteboard.generalPasteboard()
        if let data = pasteboard.dataForType(AppConfiguration.UTI.dateNode) {
            pasteData(data)
        }
    }
    
    @IBAction func makeEndDate(sender: AnyObject) {
        displayedPopover = nil
        
        if sequencePresenter!.timeDirection == .Forward {
            self.sequencePresenter?.setDate(sequencePresenter!.date, direction:.Backward)
        } else {
            self.sequencePresenter?.setDate(sequencePresenter!.date, direction:.Forward)
        }
    }
    
    public override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        
        switch menuItem.action {
        case #selector(DateNodeCollectionViewItem.clear(_:)),
             #selector(DateNodeCollectionViewItem.copy(_:)):
            return sequencePresenter!.date == nil ? false : true
            
        case #selector(DateNodeCollectionViewItem.paste(_:)):
            let pasteboard = NSPasteboard.generalPasteboard()
            return pasteboard.canReadItemWithDataConformingToTypes([AppConfiguration.UTI.dateNode])
            
        default:
            if self.sequencePresenter?.currentState == SequenceState.NoStartDateSet { return true }
            if self.sequencePresenter?.currentState == SequenceState.WaitingForStart { return true }
            if self.sequencePresenter?.currentState == SequenceState.Running { return true }
            return false
        }
    }
    
    
    //MARK: Pasteboard
    
    func pasteboardItem() -> NSPasteboardItem {
        let date:NSDate
        if sequencePresenter!.date != nil { date = sequencePresenter!.date! } else {
            date = NSDate.distantPast()
        }
        let dictionary = ["date":date, "timeDirection" : sequencePresenter!.timeDirection.rawValue]
        let data = NSKeyedArchiver.archivedDataWithRootObject(dictionary)
        let item = NSPasteboardItem()
        item.setData(data, forType: AppConfiguration.UTI.dateNode)
        return item
    }
    
    func pasteData(data:NSData) {
        let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Dictionary <String, AnyObject>
        let date = (dict["date"] as! NSDate)
        if date.isEqualToDate(NSDate.distantPast()) == true {
            self.sequencePresenter!.setDate(nil, direction:(TimeDirection(rawValue: (dict["timeDirection"] as! Int)))!)
        } else {
            self.sequencePresenter!.setDate((dict["date"] as! NSDate), direction:(TimeDirection(rawValue: (dict["timeDirection"] as! Int)))!)
        }
        updateView()
    }
    
    
    //MARK: Drag & Drop
    
    func isDraggable() -> Bool {
        if sequencePresenter!.date == nil { return false }
        return true
    }
    
    func draggingItem() -> NSPasteboardWriting? {
        return pasteboardItem()
    }
    
    func validateDrop(item: NSPasteboardItem, proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        //  if proposedDropOperation.memory == .Before { return .None }
        if item.types[0] == AppConfiguration.UTI.dateNode {
            //TODO: Can't drop on it's self
            return .Copy
        } else if item.types[0] == AppConfiguration.UTI.node {
            return .Copy
        }
        
        return .None
    }
    
    func acceptDrop(collectionView: NSCollectionView, item: NSPasteboardItem, dropOperation: NSCollectionViewDropOperation) -> Bool {
        if let data = item.dataForType(AppConfiguration.UTI.dateNode) {
            pasteData(data)
            return true
        } else {
            return false
        }
    }
    
    //MARK Popover delegate
    
    public func popoverDidClose(notification: NSNotification) {
        displayedPopover = nil
    }
}