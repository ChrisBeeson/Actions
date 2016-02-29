//
//  CalendarEventsToAvoidPeriods.swift
//  Filament
//
//  Created by Chris Beeson on 25/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools
import EventKit

 class AvoidCalendarEvents: Rule, NSCoding {
    
    // This rule sits the duration of an event.
    // It allows the event to be shortened to a minimum duration if required.
    
     override var name: String { return "RULE_NAME_AVOID_CALS".localized }
     override var availableToNodeType:NodeType { return .All}
     override var conflictingRules: [Rule]? { return nil }
     override var options: RoleOptions { get { return RoleOptions.RequiresInterestWindow } }
    
    
    // Custom Vars
    
     var calendars = [EKCalendar]()
    
     init(calendars:[EKCalendar]) {
        self.calendars = calendars
    }
    
     override init() {
        super.init()
    }
    
    
     override var avoidPeriods: [DTTimePeriod]? {
        
        get {
            
            if interestPeriod == nil { return nil }
            
            // 1. Find the calendar events for the time period.
          
            guard let events = CalendarManager.sharedInstance.events(interestPeriod!, calendars: calendars) else {
                 return nil
            }
            
            // 2. Turn each event into a time period.
            
            var periods = [DTTimePeriod]()
            
            for event in events {
                
                let period = DTTimePeriod(startDate: event.startDate, endDate: event.endDate)
                
                periods.append(period)
            }
            
            return periods
        }
        
        set {
            self.avoidPeriods = newValue
        }
    }
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        static let duration = "duration"
        static let minDuration = "minDuration"
    }
    
     required init?(coder aDecoder: NSCoder) {
       calendars = aDecoder.decodeObjectForKey("calendars") as! [EKCalendar]
    }
    
     func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(calendars, forKey:"calendars")
    }
}