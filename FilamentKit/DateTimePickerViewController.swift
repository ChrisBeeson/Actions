//
//  DateTimePickerViewController.swift
//  Filament
//
//  Created by Chris Beeson on 13/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import PopDatePicker

public protocol DateTimePickerViewDelegate {
    
    func dateTimePickerDidChangeDate(date:NSDate?)
}

public class DateTimePickerViewController : NSViewController {
    
    @IBOutlet weak var datePicker: PopDatePicker!
    @IBOutlet weak var timePicker: PopDatePicker!
    
    var delegate: DateTimePickerViewDelegate?
    
    public var date:NSDate?
    var trashPressed = false
    
    
    public override func viewDidLoad() {
        
        datePicker.shouldShowPopover = {
            return true
        }
        
        timePicker.shouldShowPopover = {
            return false
        }
        
        datePicker.preferredPopoverEdge = .MinY
    }
    
    
    public override func viewWillAppear() {
        super.viewWillAppear()
        
        if date == nil {
            date = NSDate()
        } else if date!.isEarlierThan(NSDate()) {
            date = NSDate()
        }
        
        datePicker.dateValue = date!
        timePicker.dateValue = date!
    }
    
    
    public  override func viewWillDisappear() {
        super.viewWillDisappear()
        
        if trashPressed == false {
            delegate?.dateTimePickerDidChangeDate(combineDateWithTime(datePicker.dateValue, time: timePicker.dateValue))
        }
        trashPressed = false
    }
    
    
    @IBAction func trashPressed(sender: AnyObject) {
        
        delegate?.dateTimePickerDidChangeDate(nil)
        trashPressed = true
        
       
    }
    
    
    @IBAction func nowPressed(sender: AnyObject) {
        
        datePicker.dateValue = NSDate()
        timePicker.dateValue = NSDate()
    }
    
    
    func combineDateWithTime(date: NSDate, time: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([.Year, .Month, .Day], fromDate: date)
        let timeComponents = calendar.components([.Hour, .Minute, .Second], fromDate: time)
        
        let components = NSDateComponents()
        components.year = dateComponents.year
        components.month = dateComponents.month
        components.day = dateComponents.day
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = timeComponents.second
        
        return calendar.dateFromComponents(components)!
    }
}
