//
//  CalendarEventsToAvoidPeriods.swift
//  Actions
//
//  Created by Chris Beeson on 25/09/2015.
//  Copyright © 2016 Andris Ltd. All rights reserved.

import Foundation
import DateTools
import EventKit
import ObjectMapper

class AvoidCalendarEventsRule : Rule {
    
    //TODO: Add ignore all day events
    
    // This rule sits the duration of an event.
    // It allows the event to be shortened to a minimum duration if required.
    
    override var name: String { return "RULE_NAME_AVOID_CALS".localized }
    override var availableToNodeType: NodeType { return [.Generic] }
    override var options: RoleOptions { get { return RoleOptions.RequiresInterestWindow } }
    
    var calendars = [Calendar]()
    var ignoreCurrentEventsForSequence: Sequence?
    var ignoreCurrentEventForNode: Node?
    
    override init() {
        super.init()
        populateCalendars()
    }
    
    /*
    override var avoidPeriods: [AvoidPeriod]? {
        get {
            if interestPeriod == nil { return nil }
            
            // 1. Get active calendars
            let activeCalendars = calendars.filter { $0.avoid == true }
            // activeCalendars.forEach{ print("Using Calendar:\($0.name)  \($0.avoid)") }
            guard let events = CalendarManager.sharedInstance.events(interestPeriod!, calendars:activeCalendars) else { return nil }
            
            // 2. Turn each event into a time period.
            var periods = [AvoidPeriod]()
            for event in events {
                let period = DTTimePeriod(startDate: event.startDate, endDate: event.endDate)
                let ignore = ignorePeriods()?.filter{ $0.isEqualToPeriod(period) }
                if ignore == nil || ignore!.count == 0 {
                    let avoidPeriod = AvoidPeriod(period: period, type: .CalendarEvent, object: event)
                    periods.append(avoidPeriod)
                }
            }
            return periods
        }
        
        set {
            self.avoidPeriods = newValue   // For testing only
        }
    }
   */
    

    override var avoidPeriods: [AvoidPeriod]? {
        get {
            if interestPeriod == nil { return nil }
            
            // 1. Get active calendars
            let activeCalendars = calendars.filter { $0.avoid == true }
            // activeCalendars.forEach{ print("Using Calendar:\($0.name)  \($0.avoid)") }
            guard let events = CalendarManager.sharedInstance.events(interestPeriod!, calendars:activeCalendars) else { return nil }
            
            // 2. Turn each event into a time period.
            var periods = [AvoidPeriod]()
            for event in events {
                let period = DTTimePeriod(startDate: event.startDate, endDate: event.endDate)
                var addPeriod = true
                
                if let ignores = ignorePeriods() {
                    for ignore in ignores {
                        if abs(period.StartDate.secondsFrom(ignore.StartDate!)) < 60 && abs(period.EndDate.secondsFrom(ignore.EndDate!)) < 60 {
                            addPeriod = false
                        }
                    }
                }
                
                if addPeriod == true {
                    let avoidPeriod = AvoidPeriod(period: period, type: .CalendarEvent, object: event)
                    periods.append(avoidPeriod)
                }
            }
            return periods
        }
        
        set {
            self.avoidPeriods = newValue   // For testing only
        }
    }
 

    
    func ignorePeriods() -> [DTTimePeriod]? {
        var periods = [DTTimePeriod]()
        
        if ignoreCurrentEventForNode != nil {
            if let event = ignoreCurrentEventForNode!.event {
                let period = DTTimePeriod(startDate: event.startDate, endDate: event.endDate)
                periods.append(period)
            }
        }
        
        if ignoreCurrentEventsForSequence != nil {
            for node in ignoreCurrentEventsForSequence!.nodeChain() {
                if let event = node.event {
                    let period = DTTimePeriod(startDate: event.startDate, endDate: event.endDate)
                    print("Created Period to ignore \(period)")
                    periods.append(period)
                }
            }
        }
        return periods
    }
    
    
    func populateCalendars() {
        // Calendars stored in Rule
        var currentCalendars = self.calendars
        
        // Get all system calendars
        let systemCalendars = CalendarManager.sharedInstance.systemCalendarsAsCalendars()
        let diff = currentCalendars.diff(systemCalendars)
        
        if diff.results.count > 0 {
            let inserts = diff.insertions.map{ $0.value }
            //TODO: Localize this
            inserts.filter({$0.name!.lowercaseString.containsString("birthday") == true}).forEach {$0.avoid = false }
            inserts.filter({$0.name!.lowercaseString.containsString("holidays") == true}).forEach {$0.avoid = false }
            currentCalendars.appendContentsOf(inserts)
            
            let deletions = diff.deletions.map{ $0.value }
            currentCalendars.removeObjects(deletions)
        }
        self.calendars = currentCalendars
    }
    
    
    // MARK: NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        calendars = aDecoder.decodeObjectForKey("calendars") as! Array
        self.populateCalendars()
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(calendars, forKey:"calendars")
    }
    
    
    // MARK: NSCopying
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
         let clone = AvoidCalendarEventsRule()
         clone.calendars = self.calendars
         return clone
    }
    
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        calendars        <- map["calendars"]
    }
}