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

// We only deal with calendar Identifiers

class AvoidCalendarEvents: Rule, NSCoding {
    
    // This rule sits the duration of an event.
    // It allows the event to be shortened to a minimum duration if required.
    
     override var name: String { return "RULE_NAME_AVOID_CALS".localized }
     override var availableToNodeType:NodeType { return .All}
     override var conflictingRules: [Rule]? { return nil }
     override var options: RoleOptions { get { return RoleOptions.RequiresInterestWindow } }
    
    
    // Custom Vars
    
    var calendarDictionary = [String : Bool]()
    
     init(calendarIdenifier:String) {
        super.init()
        addCalendarIdentifier(calendarIdenifier, avoid: true)
    }

    
     override init() {
        super.init()
    }
    
    
    func addCalendarIdentifier(identifier: String, avoid: Bool) {
        
        calendarDictionary[identifier] = avoid
    }
    
    
     override var avoidPeriods: [DTTimePeriod]? {
        
        get {
            
            if interestPeriod == nil { return nil }
            
            // 1. Find the calendar events for the time period.
            // var identifiers : [String] = calendars.filter{ $0.selected == true }.map { $0.calendarIdentifier }
            
            var ids = [String]()
            
            for (id , active) in calendarDictionary {
                if active == true {
                  ids.append(id)
                }
            }
          
            guard let events = CalendarManager.sharedInstance.events(interestPeriod!, calendarIdentifiers:ids) else {
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
            self.avoidPeriods = newValue   // For testing only
        }
    }
    
    // MARK: NSCoding
    
     required init?(coder aDecoder: NSCoder) {
       calendarDictionary = aDecoder.decodeObjectForKey("calendarDictionary") as! Dictionary
    }
    
     func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(calendarDictionary, forKey:"calendarDictionary")
    }
}