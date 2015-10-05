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

public struct AvoidCalendarEvents: RuleType {
    
    // This rule sits the duration of an event.
    // It allows the event to be shortened to a minimum duration if required.
    
    
    public var name: String { return "!!!" }
    public var availableToNodeType:NodeType { return .None}
    public var conflictingRules: [RuleType]? { return nil }
    
    public var inputDate: NSDate?
    
    public var interestPeriod: DTTimePeriod
    public var calendars: [EKCalendar]
    
    public init(interestPeriod: DTTimePeriod, calendars:[EKCalendar]) {
        
        self.interestPeriod = interestPeriod
        self.calendars = calendars
    }
    
    
    // Rule protocol requirements
    
    public var eventStartTimeWindow: DTTimePeriod? { get { return nil } }
    public var eventPreferedStartDate: NSDate? { get { return nil } }
    
    public var eventMaxDuration: TimeSize? { get { return nil } }
    public var eventMinDuration: TimeSize? { get { return nil} }
    public var eventPreferedDuration: TimeSize? { get { return nil } }
    
    public var avoidPeriods: [DTTimePeriod]? {
        
        get {
            
            // 1. Find the calendar events for the time period.
          
            guard let events = CalendarManager.sharedInstance.events(interestPeriod, calendars: calendars) else {
                
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