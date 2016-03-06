//
//  AvoidCalendarsPresenter.swift
//  Filament
//
//  Created by Chris Beeson on 5/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class AvoidCalendarEventsPresenter : RulePresenter {
    
    public func calendars() -> [Calendar] {
        
        // Calendars stored in Rule
        var currentCalendars = (rule as! AvoidCalendarEventsRule).calendars
        
        // Get all system calendars
        let systemCalendars = CalendarManager.sharedInstance.systemCalendarsAsCalendars()
        
        let diff = currentCalendars.diff(systemCalendars)
        
        if diff.results.count > 0 {
         
            Swift.print("Calendar Diff count \(diff.results.count)")
                
            let inserts = diff.insertions.map{ $0.value }
            currentCalendars.appendContentsOf(inserts)
            
            let deletions = diff.deletions.map{ $0.value }
            currentCalendars.removeObjects(deletions)
        }
        
        (rule as! AvoidCalendarEventsRule).calendars = currentCalendars
        
        return currentCalendars
    }
    
    
    public func setCalendarAvoidState(calendar:Calendar, avoid:Bool) {
        
        if let index = (rule as! AvoidCalendarEventsRule).calendars.indexOf(calendar) where index != -1 {
            let cal = (rule as! AvoidCalendarEventsRule).calendars[index]
            cal.avoid = avoid
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
