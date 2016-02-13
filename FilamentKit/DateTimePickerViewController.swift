//
//  DateTimePickerViewController.swift
//  Filament
//
//  Created by Chris Beeson on 13/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import PopDatePicker

public class DateTimePickerViewController : NSViewController {
    
    @IBOutlet weak var datePicker: PopDatePicker!
    
    @IBOutlet weak var timePicker: PopDatePicker!
    
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
        datePicker.dateValue = NSDate()
    }
    
    
}
