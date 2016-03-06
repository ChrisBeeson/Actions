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

        let filter = CIFilter(name: "CIColorMonochrome")

        //Swift.print(filter?.attributes)
        let colour = CIColor(color: calendar.colour!)
        filter?.setValue(colour, forKey: "inputColor")
        checkbox.layer!.filters = [filter!]

        calendarCheckboxes[calendar] = checkbox
        return checkbox
    }
}
