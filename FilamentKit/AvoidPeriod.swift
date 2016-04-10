//
//  AvoidPeriod.swift
//  Filament
//
//  Created by Chris Beeson on 9/04/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

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
    
    var humanReadableString:String? {
        switch self.type {
        case .CalendarEvent:
            if let event = (object as? EKEvent) {
                return event.title
            } else { return nil }
        case .WorkingWeekMorning: return "RUlE_WORKING_WEEK_MORNING".localized
        case .WorkingWeekEvening: return "RUlE_WORKING_WEEK_EVENING".localized
        case .WorkingWeekLunch: return "RUlE_WORKING_WEEK_LUNCH".localized
        case .WorkingWeekDayOff: return "RUlE_WORKING_WEEK_DAY_OFF".localized
        case .Node:
            return object != nil ? (object as! Node).title : nil
        default: return nil
        }
    }
}

enum AvoidPeriodType {
    case CalendarEvent
    case WorkingWeekMorning
    case WorkingWeekEvening
    case WorkingWeekLunch
    case WorkingWeekDayOff
    case Node
    case None
}
