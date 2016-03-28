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
    
    @IBOutlet weak var month: NSTextField!
    @IBOutlet weak var day: NSTextField!
    @IBOutlet weak var dayString: NSTextField!
    @IBOutlet weak var time: NSTextField!
    @IBOutlet weak var circleView: EmptyNodeView!
    @IBOutlet weak var transitionView: TransitionNodeView!
    
    weak var sequencePresenter: SequencePresenter?
    var displayedPopover: NSPopover?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func viewWillAppear() {
        super.viewWillAppear()
        
    }
    
    override public func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
        
        //  if theEvent.clickCount < 2 { return }
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
        popover.showRelativeToRect(self.dayString!.frame, ofView: self.view, preferredEdge:.MinX )
        displayedPopover = popover
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
    
    public func sequencePresenterDidChangeState(sequencePresenter: SequencePresenter, toState:SequenceState) {
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