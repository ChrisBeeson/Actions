//
//  AvoidCalendarViewController.swift
//  Actions
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
        
        if CalendarManager.sharedInstance.authorized == true {
            calendars = (rulePresenter as! AvoidCalendarEventsPresenter).calendars
            for cal in calendars {
                let view = stackViewForCalendar(cal)
                vertStackView.addArrangedSubview(view)
            }
        } else {
            let textBox = NSTextField()
            textBox.bordered = false
            textBox.backgroundColor = NSColor.clearColor()
            textBox.editable = false
            textBox.bezeled = false
            textBox.font = NSFont.systemFontOfSize(12.0)
            textBox.stringValue = "RULE_AVOID_CALS_UNAUTHORIZED".localized
            vertStackView.addArrangedSubview(textBox)
        }
    }
    
    
    override func viewWillDisappear() {
        if CalendarManager.sharedInstance.authorized == true {
            
            let presenter = rulePresenter as! AvoidCalendarEventsPresenter
            
            for cal in calendarCheckboxes {
                let state = (cal.1.state == NSOnState) ? true : false
                presenter.setCalendarAvoidState(cal.0, avoid:state)
            }
            if saveToContext == true { AppConfiguration.sharedConfiguration.saveContext() }
        }
        super.viewWillDisappear()
    }
    
    
    func stackViewForCalendar(calendar:Calendar) -> NSView {
        let checkbox = NSButton()
        checkbox.setButtonType(.SwitchButton)
        checkbox.title = ""
        checkbox.state = calendar.avoid ? NSOnState : NSOffState
        checkbox.wantsLayer = true
        checkbox.layerUsesCoreImageFilters = true
        let filter = CIFilter(name: "CIColorMonochrome")
        let colour = CIColor(color: calendar.colour!)
        filter!.setDefaults()
        filter!.setValue(colour, forKey: "inputColor")
        checkbox.layer!.filters = [filter!]
        checkbox.layer!.needsDisplay()
        calendarCheckboxes[calendar] = checkbox
        
        let textBox = NSTextField()
        textBox.bordered = false
        textBox.backgroundColor = NSColor.clearColor()
        textBox.editable = false
        textBox.bezeled = false
        textBox.font = NSFont.systemFontOfSize(12.0)
        
        if let name = calendar.name {
            textBox.stringValue = name
        } else {
            textBox.stringValue  = ""
        }
        
        let stackView = NSStackView()
        stackView.addArrangedSubview(checkbox)
        stackView.addArrangedSubview(textBox)
        stackView.spacing = 2.0
        return stackView
    }
}
