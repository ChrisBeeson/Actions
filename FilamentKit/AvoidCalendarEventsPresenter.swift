//
//  AvoidCalendarsPresenter.swift
//  Filament
//
//  Created by Chris Beeson on 5/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class AvoidCalendarEventsPresenter : RulePresenter {
    
    public var calendars: [Calendar] {
        get {
            return (self.rule as! AvoidCalendarEventsRule).calendars
        }
    }
    
    public func setCalendarAvoidState(calendar:Calendar, avoid:Bool) {
        if let index = (rule as! AvoidCalendarEventsRule).calendars.indexOf(calendar) where index != -1 {
            let cal = (rule as! AvoidCalendarEventsRule).calendars[index]
            cal.avoid = avoid
             sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
        } else {
            print("index of the calendar was -1")
        }
    }
    
    public override func detailViewController() -> RuleViewController {
        if ruleViewController == nil {
            let bundle = NSBundle(identifier:"com.andris.FilamentKit")
            ruleViewController = AvoidCalendarEventsViewController(nibName:"AvoidCalendarEventsViewController", bundle:bundle)!
            ruleViewController!.rulePresenter = self
        }
        return ruleViewController!
    }
}
