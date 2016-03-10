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
    @IBOutlet weak var setButton: NSButton!
    
    var delegate: DateTimePickerViewDelegate?
    
    public var date:NSDate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .Center
        
        setButton.attributedTitle = NSAttributedString(string: "Set", attributes: [ NSForegroundColorAttributeName : AppConfiguration.Palette.buttonSelectionBlue, NSParagraphStyleAttributeName : pstyle, NSFontAttributeName : NSFont.systemFontOfSize(10.0) ])
    }
    
    
    public override func viewWillAppear() {
        super.viewWillAppear()
        
        if date == nil {
            date = NSDate()
        }
    
        datePicker.dateValue = date!
        timePicker.dateValue = date!
    }
    
    
    public  override func viewWillDisappear() {
        super.viewWillDisappear()
        
    }
    
    @IBAction func setPressed(sender: AnyObject) {
        
    delegate?.dateTimePickerDidChangeDate(combineDateWithTime(datePicker.dateValue, time: timePicker.dateValue))
    }
    
    @IBAction func trashPressed(sender: AnyObject) {
        
        delegate?.dateTimePickerDidChangeDate(nil)
    }
    
    
    @IBAction func nowPressed(sender: AnyObject) {
        
        datePicker.dateValue = NSDate()
        datePicker.setNeedsDisplay()
        timePicker.dateValue = NSDate()
        timePicker.setNeedsDisplay()
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
