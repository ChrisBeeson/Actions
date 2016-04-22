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

extension NSDate {
    
    func dateByAddingTimesize(size: Timesize) -> NSDate {
        
        switch size.unit {
        case .Second: return self.dateByAddingSeconds(size.amount)
        case .Minute: return self.dateByAddingMinutes(size.amount)
        case .Hour: return self.dateByAddingHours(size.amount)
        case .Day: return self.dateByAddingDays(size.amount)
        case .Week: return self.dateByAddingWeeks(size.amount)
        case .Month: return self.dateByAddingMonths(size.amount)
        case .Year:return self.dateByAddingYears(size.amount)
        }
    }
    
    func dateBySubtractingTimesize(size: Timesize) -> NSDate {
        
        switch size.unit {
        case .Second: return self.dateBySubtractingSeconds(size.amount)
        case .Minute: return self.dateBySubtractingMinutes(size.amount)
        case .Hour: return self.dateBySubtractingHours(size.amount)
        case .Day: return self.dateBySubtractingDays(size.amount)
        case .Week: return self.dateBySubtractingWeeks(size.amount)
        case .Month: return self.dateBySubtractingMonths(size.amount)
        case .Year:return self.dateBySubtractingYears(size.amount)
        }
    }
    
    class func dateFromString(string: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        return dateFormatter.dateFromString(string)!
    }
}

extension DTTimePeriod {
    
     override public var description: String { return "\(StartDate) ->  \(EndDate)"}
    
    public func log() ->String {
        let startTime = self.StartDate.formattedDateWithFormat("DD:MM:YY HH:mm")
        let endTime = self.EndDate.formattedDateWithFormat("DD:MM:YY HH:mm")
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

            guard let periodStart = period.StartDate, let periodEnd = period.EndDate else { continue }

            if !flatdate.hasStartDate() { flatdate.StartDate = periodStart }
            if !flatdate.hasEndDate() { flatdate.EndDate = periodEnd }
            
            if periodStart.isEarlierThanOrEqualTo(flatdate.EndDate) && periodEnd.isGreaterThanOrEqualTo(flatdate.EndDate) {
                
                flatdate.EndDate = periodEnd
                
            } else {
                
                flattenedPeriods.append(flatdate.copy())
                flatdate.StartDate = periodStart
                flatdate.EndDate = periodEnd
            }
        }
        
        flattenedPeriods.append(flatdate.copy())
        
        // delete all periods
        for _ in 0  ..< periods.count  { self.removeTimePeriodAtIndex(0) }
        
        // add flattened periods to self
        
        //   print("Flattened to:")
        for flat in flattenedPeriods {
            //   print(flat.description)
            self.addTimePeriod(flat)
        }
    }

    
    func voidPeriods(inPeriod: DTTimePeriod) -> DTTimePeriodCollection {
        
        if self.periods() == nil || self.periods()!.count == 0 {
            let samePeriod = DTTimePeriodCollection()
            samePeriod.addTimePeriod(inPeriod.copy())
            return samePeriod
        }
        
        let periods = self.periods()!
        let voidPeriods = DTTimePeriodCollection()
        
        // First gaps between the edges of the window of interest.
        
        if inPeriod.StartDate.isEarlierThan(periods[0].StartDate) {
            let newVoidPeriod = DTTimePeriod()
            newVoidPeriod.StartDate = inPeriod.StartDate
            newVoidPeriod.EndDate = periods[0].StartDate
            voidPeriods.addTimePeriod(newVoidPeriod)
        }
        
        if periods[periods.count-1].EndDate.isEarlierThan(inPeriod.EndDate) {
            let newVoidPeriod = DTTimePeriod()
            newVoidPeriod.StartDate = periods[periods.count-1].EndDate
            newVoidPeriod.EndDate = inPeriod.EndDate
            voidPeriods.addTimePeriod(newVoidPeriod)
        }
    
        // void periods in between the periods
        
        for i in 0  ..< periods.count  {
            if i < (periods.count - 1) {
                if periods[i].EndDate!.isEarlierThan(periods[i+1].StartDate!) {
                    let voidPeriod = DTTimePeriod()
                    //  voidPeriod.StartDate = periods[i].EndDate!.dateByAddingSeconds(1)
                    //  voidPeriod.EndDate = periods[i+1].StartDate!.dateBySubtractingSeconds(1)
                    voidPeriod.StartDate = periods[i].EndDate!
                    voidPeriod.EndDate = periods[i+1].StartDate!
                    voidPeriods.addTimePeriod(voidPeriod)
                }
            }
        }
        voidPeriods.sortByStartAscending()
        return voidPeriods
    }
    
     override public var description: String {
        guard let periods = self.periods() else { return "No Periods" }
        
        var string = String()
        for period in periods {
            string.appendContentsOf(period.description + "\n")
        }
        return string
    }
}