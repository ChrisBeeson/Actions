//
//  AvoidPeriod.swift
//  Actions
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
        self.type = .none
    }
    
    var errorDescription: String? {
        switch self.type {
        case .calendarEvent:
            if let event = (object as? EKEvent) {
                return event.title
            } else { return nil }
        case .workingWeekMorning: return "RUlE_WORKING_WEEK_MORNING".localized
        case .workingWeekEvening: return "RUlE_WORKING_WEEK_EVENING".localized
        case .workingWeekLunch: return "RUlE_WORKING_WEEK_LUNCH".localized
        case .workingWeekDayOff: return "RUlE_WORKING_WEEK_DAY_OFF".localized
        case .node:
            return object != nil ? (object as! Node).title : nil
        default: return nil
        }
    }
}

enum AvoidPeriodType {
    case calendarEvent
    case workingWeekMorning
    case workingWeekEvening
    case workingWeekLunch
    case workingWeekDayOff
    case node
    case none
}
