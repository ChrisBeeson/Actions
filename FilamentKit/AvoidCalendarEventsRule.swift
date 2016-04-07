//
//  CalendarEventsToAvoidPeriods.swift
//  Filament
//
//  Created by Chris Beeson on 25/09/2015.
//  Copyright © 2016 Andris Ltd. All rights reserved.

import Foundation
import DateTools
import EventKit

struct AvoidPeriod {
    var period:DTTimePeriod
    var type:AvoidPeriodType
    var object:AnyObject?
    
    init (period:DTTimePeriod, type:AvoidPeriodType, object:AnyObject?) {
        self.period = period
        self.type = type
        self.object = object
    }
    
    init (period:DTTimePeriod) {
        self.period = period
        self.type = .None
    }
}

enum AvoidPeriodType {
    case CalendarEvent
    case WorkingWeekMorning
    case WorkingWeekEvening
    case WorkingWeekLunch
    case Node
    case None
}

class AvoidCalendarEventsRule: Rule, NSCoding {
    
    // This rule sits the duration of an event.
    // It allows the event to be shortened to a minimum duration if required.
    
    override var name: String { return "RULE_NAME_AVOID_CALS".localized }
    override var availableToNodeType: NodeType { return [.Generic] }
    override var conflictingRules: [Rule]? { return nil }
    override var options: RoleOptions { get { return RoleOptions.RequiresInterestWindow } }
    
    var calendars = [Calendar]()
    var ignoreCurrentEventsForSequence: Sequence?
    var ignoreCurrentEventForNode: Node?
    
    override init() {
        super.init()
        populateCalendars()
    }
    
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
        calendars = aDecoder.decodeObjectForKey("calendars") as! Array
        super.init()
        self.populateCalendars()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(calendars, forKey:"calendars")
    }
}