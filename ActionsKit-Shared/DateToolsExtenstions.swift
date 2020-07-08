//
//  DateToolsExtenstions.swift
//  Actions
//
//  Created by Chris Beeson on 25/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools
import ObjectMapper

extension Date {
    
    func dateByAddingTimesize(_ size: Timesize) -> Date {
        
        switch size.unit {
        case .second: return (self as NSDate).addingSeconds(size.amount)
        case .minute: return (self as NSDate).addingMinutes(size.amount)
        case .hour: return (self as NSDate).addingHours(size.amount)
        case .day: return (self as NSDate).addingDays(size.amount)
        case .week: return (self as NSDate).addingWeeks(size.amount)
        case .month: return (self as NSDate).addingMonths(size.amount)
        case .year:return (self as NSDate).addingYears(size.amount)
        }
    }
    
    func dateBySubtractingTimesize(_ size: Timesize) -> Date {
        
        switch size.unit {
        case .second: return (self as NSDate).subtractingSeconds(size.amount)
        case .minute: return (self as NSDate).subtractingMinutes(size.amount)
        case .hour: return (self as NSDate).subtractingHours(size.amount)
        case .day: return (self as NSDate).subtractingDays(size.amount)
        case .week: return (self as NSDate).subtractingWeeks(size.amount)
        case .month: return (self as NSDate).subtractingMonths(size.amount)
        case .year:return (self as NSDate).subtractingYears(size.amount)
        }
    }
    
    static func dateFromString(_ string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.date(from: string)!
    }
}

extension DTTimePeriod {
    
     override open var description: String { return "\(startDate) ->  \(endDate)"}
    
    public func log() ->String {
        let startTime = self.startDate.formattedDate(withFormat: "DD:MM:YY HH:mm")
        let endTime = self.endDate.formattedDate(withFormat: "DD:MM:YY HH:mm")
        return("\(startTime) -> \(endTime)")
    }
}

extension DTTimePeriodGroup {
    
     func periods() -> [DTTimePeriod]? {
        
        if self.count() == 0 { return nil }
        
        var periods = [DTTimePeriod]()
        for i in 0  ..< self.count()  { periods.append(self[UInt(i)] as! DTTimePeriod) }
        return periods
    }
}


extension DTTimePeriodCollection {
    
    func flatten() {
        
        self.sortByStartAscending()
    
        guard let periods = self.periods() else { return }

        var flattenedPeriods = [DTTimePeriod]()
        let flatdate = DTTimePeriod()
    
        for period in periods {

            guard let periodStart = period.startDate, let periodEnd = period.endDate else { continue }

            if !flatdate.hasStartDate() { flatdate.startDate = periodStart }
            if !flatdate.hasEndDate() { flatdate.endDate = periodEnd }
            
            if (periodStart as NSDate).isEarlierThanOrEqual(to: flatdate.endDate) && periodEnd.isGreaterThanOrEqual(to: flatdate.endDate) {
                
                flatdate.endDate = periodEnd
                
            } else {
                
                flattenedPeriods.append(flatdate.copy())
                flatdate.startDate = periodStart
                flatdate.endDate = periodEnd
            }
        }
        
        flattenedPeriods.append(flatdate.copy())
        
        // delete all periods
        for _ in 0  ..< periods.count  { self.removeTimePeriod(at: 0) }
        
        // add flattened periods to self
        for flat in flattenedPeriods {
            self.add(flat)
        }
    }

    
    func voidPeriods(_ inPeriod: DTTimePeriod) -> DTTimePeriodCollection {
        
        if self.periods() == nil || self.periods()!.count == 0 {
            let samePeriod = DTTimePeriodCollection()
            samePeriod.add(inPeriod.copy())
            return samePeriod
        }
        
        let periods = self.periods()!
        let voidPeriods = DTTimePeriodCollection()
        
        // First gaps between the edges of the window of interest.
        
        if inPeriod.startDate.isEarlierThan(periods[0].startDate) {
            let newVoidPeriod = DTTimePeriod()
            newVoidPeriod.startDate = inPeriod.startDate
            newVoidPeriod.endDate = periods[0].startDate
            voidPeriods.add(newVoidPeriod)
        }
        
        if periods[periods.count-1].endDate.isEarlierThan(inPeriod.endDate) {
            let newVoidPeriod = DTTimePeriod()
            newVoidPeriod.startDate = periods[periods.count-1].endDate
            newVoidPeriod.endDate = inPeriod.endDate
            voidPeriods.add(newVoidPeriod)
        }
    
        // void periods in between the periods
        
        for i in 0  ..< periods.count  {
            if i < (periods.count - 1) {
                if (periods[i].endDate! as NSDate).isEarlierThan(periods[i+1].startDate!) {
                    let voidPeriod = DTTimePeriod()
                    //  voidPeriod.StartDate = periods[i].EndDate!.dateByAddingSeconds(1)
                    //  voidPeriod.EndDate = periods[i+1].StartDate!.dateBySubtractingSeconds(1)
                    voidPeriod.startDate = periods[i].endDate!
                    voidPeriod.endDate = periods[i+1].startDate!
                    voidPeriods.add(voidPeriod)
                }
            }
        }
        voidPeriods.sortByStartAscending()
        return voidPeriods
    }
    
     override open var description: String {
        guard let periods = self.periods() else { return "No Periods" }
        
        var string = String()
        for period in periods {
            string.append(period.description + "\n")
        }
        return string
    }
}
