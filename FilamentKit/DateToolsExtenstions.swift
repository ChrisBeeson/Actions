//
//  DateToolsExtenstions.swift
//  Filament
//
//  Created by Chris Beeson on 25/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

extension NSDate {
    
    func dateByAddTimeSize(size: TimeSize) -> NSDate {
        
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
}


extension DTTimePeriodGroup {
    
    public func periods() -> [DTTimePeriod]? {
        
        if self.count() == 0 { return nil }
        
        var periods = [DTTimePeriod]()
        for var i = 0 ; i < self.count() ; ++i { periods.append(self[UInt(i)] as! DTTimePeriod) }
        return periods
    }
}


extension DTTimePeriodCollection {
    
    func flatten() -> DTTimePeriodCollection? {
        
        self.sortByStartAscending()
        
        guard let periods = self.periods() else { return nil }
        if periods.count < 1 { return nil}
    
        var flattenedPeriods = [DTTimePeriod]()
        let flatdate = DTTimePeriod()
        
        // flatdate.StartDate = periods[0].StartDate!
        //flatdate.EndDate = periods[0].EndDate!
        
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
        
        let chain = DTTimePeriodCollection()
        for flat in flattenedPeriods { chain.addTimePeriod(flat) }
        
        return chain
    }

    
    func voidPeriods() -> [DTTimePeriod]? {
        
        let periods = self.periods()!
        if periods.count < 2 { return nil }
        
        var voidPeriods = [DTTimePeriod]()
        
        for var i = 0 ; i < periods.count ; ++i {
            
            if i < (periods.count - 1) {
                
                if periods[i].EndDate!.isEarlierThan(periods[i+1].StartDate!) {
                    
                    let voidPeriod = DTTimePeriod()
                    voidPeriod.StartDate = periods[i].EndDate!.dateByAddingSeconds(1)
                    voidPeriod.EndDate = periods[i+1].StartDate!.dateBySubtractingSeconds(1)
                    
                    voidPeriods.append(voidPeriod)
                }
            }
        }
        
        return voidPeriods
    }
}