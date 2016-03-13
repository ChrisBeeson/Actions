//
//  AvoidCalendarViewController.swift
//  Filament
//
//  Created by Chris Beeson on 5/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import AppKit

class AvoidCalendarEventsViewController : RuleViewController , RulePresenterDelegate  {

    @IBOutlet weak var vertStackView: NSStackView!
    
    var calendars = [Calendar]()
    var calendarCheckboxes = [Calendar : NSButton]()
    var saveToContext = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendars = (rulePresenter as! AvoidCalendarEventsPresenter).calendars()
        
        for cal in calendars {
            let view = stackViewForCalendar(cal)
            vertStackView.addArrangedSubview(view)
        }
    }
    
    
    override func viewWillLayout() {
        super.viewWillLayout()
    }
    
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        let presenter = rulePresenter as! AvoidCalendarEventsPresenter
        
        for cal in calendarCheckboxes {
            let state = (cal.1.state == NSOnState) ? true : false
            presenter.setCalendarAvoidState(cal.0, avoid:state)
        }
        
        if saveToContext == true { AppConfiguration.sharedConfiguration.saveContext() }
    }
    
    func stackViewForCalendar(calendar:Calendar) -> NSView {
        
        let checkbox = NSButton()
        checkbox.setButtonType(.SwitchButton)
        if let name = calendar.name {
            checkbox.title = name
        } else {
            checkbox.title = ""
        }
        
        checkbox.state = calendar.avoid ? NSOnState : NSOffState
        checkbox.wantsLayer = true

        //TODO: Color checkbox to colour of Calendar
        let filter = CIFilter(name: "CIColorMonochrome")
        //Swift.print(filter?.attributes)
        let colour = CIColor(color: calendar.colour!)
        filter!.setDefaults()
        filter!.setValue(colour, forKey: "inputColor")
        checkbox.layer!.filters = [filter!]

        calendarCheckboxes[calendar] = checkbox
        return checkbox
    }
}
