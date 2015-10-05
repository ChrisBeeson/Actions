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
    
    func flatten() -> DTTimePeriodChain? {
        
        self.sortByStartAscending()
        
        guard var periods = self.periods() else { return nil }
        if periods.count < 1 { return nil}
    
        var flattenedPeriods = [DTTimePeriod]()
        let flatdate = DTTimePeriod()

        flatdate.StartDate = periods[0].StartDate!
        flatdate.EndDate = periods[0].EndDate!
        
        periods.removeAtIndex(0)
        
        for period in periods {
            
            // print("StartDate: (/period.startDate) EndDate: (/period.startDate)")
            
            // This isn't working cos the dates are equal!
            
            
            if period.StartDate!.isEarlierThan(flatdate.EndDate) && period.EndDate!.isGreaterThan(flatdate.EndDate) {
                
                flatdate.EndDate = period.EndDate
                
            } else {
                
                flattenedPeriods.append(flatdate.copy())    //copy?
            
                flatdate.StartDate = period.StartDate!
                flatdate.EndDate = period.EndDate!
            }
        }
        
        flattenedPeriods.append(flatdate.copy())
        
        let chain = DTTimePeriodChain()
        for flat in flattenedPeriods { chain.addTimePeriod(flat) }
        
        return chain
    }
}

/*
extension DTTimePeriodChain {
    
    func voidPeriods() -> [DTTimePeriod]? {
        
        
        if self.periods.count < 2 { return nil }
        
        
        for period in self.periods {
            
            
        }
    }
}
*/