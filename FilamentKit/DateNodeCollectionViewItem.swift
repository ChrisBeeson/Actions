//
//  DateNodeCollectionViewItem.swift
//  Filament
//
//  Created by Chris Beeson on 6/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

public class DateNodeCollectionViewItem : NSCollectionViewItem, NSPopoverDelegate, SequencePresenterDelegate, DateTimePickerViewDelegate, DragDropCopyPasteItem {
    
    @IBOutlet weak var startDateNilView: NSView!
    @IBOutlet weak var startDateNotNilView: NSView!
    @IBOutlet weak var endDateNilView: NSView!
    @IBOutlet weak var endDateNotNilView: NSView!
    
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
        
        let popover = NSPopover()
        popover.animates = true
        popover.behavior = .Transient
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        popover.delegate = self
        
        let dateTimePickerViewController  = DateTimePickerViewController(nibName:"DateTimePickerViewController", bundle:NSBundle(identifier:"com.andris.FilamentKit"))
        dateTimePickerViewController!.delegate = self
        popover.contentViewController = dateTimePickerViewController
        if sequencePresenter!.date != nil {
            dateTimePickerViewController!.date = sequencePresenter!.date!
        }
        popover.showRelativeToRect(self.view.frame, ofView: self.view, preferredEdge:.MinX )
        displayedPopover = popover
    }
    
    public func updateView() {
        self.view.alphaValue = self.sequencePresenter?.currentState == .Completed ? 0.5 : 1.0
        startDateNilView.hidden = true
        startDateNotNilView.hidden = true
        endDateNilView.hidden = true
        endDateNotNilView.hidden = true
        
        let hasDate = (sequencePresenter!.date == nil) ? false : true
        let isStartDate = sequencePresenter!.dateIsStartDate
        
        switch (hasDate, isStartDate) {
        case (false, true): startDateNilView.animator().hidden = false
        case (true, true): startDateNotNilView.animator().hidden = false
        case (false, false): endDateNilView.animator().hidden = false
        case (true, false): endDateNilView.animator().hidden = false
        }
    }
    
    public var sequenceDate: NSDate {
        if sequencePresenter == nil { return NSDate() }
        return (sequencePresenter!.date != nil) ? sequencePresenter!.date! : NSDate()
    }
    
    public var monthString: String {
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.stringFromDate(sequenceDate).capitalizedString
    }
    
    public var dayString: String {
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.stringFromDate(sequenceDate).capitalizedString
    }
    
    public var day: String {
        return String(sequenceDate.day())
    }
    
    public var time: String {
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.stringFromDate(sequenceDate)
    }
    
    // MARK: DateTimePicker delegate
    
    public func dateTimePickerDidChangeDate(date:NSDate?) {
        self.sequencePresenter!.setDate(date, isStartDate:true)
        updateView()
    }
    
    public func sequencePresenterDidChangeState(sequencePresenter: SequencePresenter, toState:SequenceState) {
         updateView()
    }
    
    
    //MARK: Menu
    
    public func clear(event: NSEvent) {
        self.sequencePresenter!.setDate(nil, isStartDate:true)
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
        //TODO: MakeEndDate
    }
    
    public override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        if self.sequencePresenter?.currentState == SequenceState.NoStartDateSet { return true }
        if self.sequencePresenter?.currentState == SequenceState.WaitingForStart { return true }
        return false
    }
    
    
    //MARK: Pasteboard
    
    func pasteboardItem() -> NSPasteboardItem {
        let date:NSDate
        if sequencePresenter!.date != nil { date = sequencePresenter!.date! } else {
            date = NSDate.distantPast()
        }
        let dictionary = ["date":date, "isStartDate":sequencePresenter!.dateIsStartDate]
        let data = NSKeyedArchiver.archivedDataWithRootObject(dictionary)
        let item = NSPasteboardItem()
        item.setData(data, forType: AppConfiguration.UTI.dateNode)
        return item
    }
    
    func pasteData(data:NSData) {
        let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Dictionary <String, AnyObject>
        let date = (dict["date"] as! NSDate)
        if date.isEqualToDate(NSDate.distantPast()) == true {
            self.sequencePresenter!.setDate(nil, isStartDate:(dict["isStartDate"] as! Bool))
        } else {
            self.sequencePresenter!.setDate((dict["date"] as! NSDate), isStartDate:(dict["isStartDate"] as! Bool))
        }
        updateView()
    }
    
    
    //MARK: Drag & Drop
    
    func isDraggable() -> Bool {
        return true
    }
    
    func draggingItem() -> NSPasteboardWriting? {
        return pasteboardItem()
    }
    
    func validateDrop(item: NSPasteboardItem, proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        //  if proposedDropOperation.memory == .Before { return .None }
        if item.types[0] == AppConfiguration.UTI.dateNode { return .Copy }
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