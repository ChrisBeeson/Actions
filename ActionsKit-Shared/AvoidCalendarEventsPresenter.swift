//
//  AvoidCalendarsPresenter.swift
//  Actions
//
//  Created by Chris Beeson on 5/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

open class AvoidCalendarEventsPresenter : RulePresenter {
    
    open var calendars: [Calendar] {
        get {
            return (self.rule as! AvoidCalendarEventsRule).calendars
        }
    }
    
    open func setCalendarAvoidState(_ calendar:Calendar, avoid:Bool) {
        if let index = (rule as! AvoidCalendarEventsRule).calendars.index(of: calendar) , index != -1 {
            let cal = (rule as! AvoidCalendarEventsRule).calendars[index]
            cal.avoid = avoid
             sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
        } else {
            print("index of the calendar was -1")
        }
    }
    
    open override func detailViewController() -> RuleViewController {
        if ruleViewController == nil {
            let bundle = Bundle(identifier:"com.andris.ActionsKit")
            ruleViewController = AvoidCalendarEventsViewController(nibName:"AvoidCalendarEventsViewController", bundle:bundle)!
            ruleViewController!.rulePresenter = self
        }
        return ruleViewController!
    }
}
