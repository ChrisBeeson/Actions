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

public struct AvoidCalendarEvents: Rule {
    
    // This rule sits the duration of an event.
    // It allows the event to be shortened to a minimum duration if required.
    
    public var name: String { return "!!!" }
    public var availableToNodeType:NodeType { return .None}
    public var conflictingRules: [Rule]? { return nil }
    public var options: RoleOptions { get { return RoleOptions.RequiresInterestWindow } }
    
    // Rule inputs
    public var inputDate: NSDate?
    public var interestPeriod: DTTimePeriod?
    
    
    // Custom Vars
    public var calendars: [EKCalendar]
    
    public init(calendars:[EKCalendar]) {
        
        self.calendars = calendars
    }
    
    
    public var avoidPeriods: [DTTimePeriod]? {
        
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
    }
}