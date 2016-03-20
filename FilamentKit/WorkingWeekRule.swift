//
//  WorkingWeekRule.swift
//  Filament
//
//  Created by Chris Beeson on 30/10/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

//TODO: Working Week

class WorkingWeekRule: Rule, NSCoding {
    
    // This rule sits the duration of an event.
    // It allows the event to be shortened to a minimum duration if required.
    
    override var name: String { return "RULE_NAME_WORK_HOURS".localized }
    override var availableToNodeType:NodeType { return [.Generic] }
    override var conflictingRules: [Rule]? { return nil }
    override var options: RoleOptions { get { return RoleOptions.RequiresInterestWindow } }
    
    //defaults
    
    var workingDayStartTime =  NSDate(string: "09:00", formatString: "HH:mm")
    var workingDayEndTime = NSDate(string: "17:30", formatString: "HH:mm")
    var workingDayEnabled = true
    var lunchBreakStartTime = NSDate(string: "12:30", formatString: "HH:mm")
    var lunchBreakEndTime = NSDate(string: "13:30", formatString: "HH:mm")
    var lunchBreakEnabled = true
    var enabledDays = [2:true, 3:true, 4:true, 5:true, 6:true, 7:false, 1:false]  // Sunday = 1
    
    
    override init() {
        super.init()
    }
    
    override var avoidPeriods: [DTTimePeriod]? {
        get {
            if interestPeriod == nil { return nil }
            
            var numberOfDays = interestPeriod?.EndDate.daysLaterThan(interestPeriod?.StartDate)
            if numberOfDays == 0 { numberOfDays =  1 }
            
            var periods = [DTTimePeriod]()
            
            for day in 0...numberOfDays! {
                
                let dayNumber = interestPeriod!.StartDate.dateByAddingDays(day).weekday()
                if enabledDays[dayNumber] == true {
                    
                    if workingDayEnabled == true {
                        
                        // go from midnight to the working day start Time
                        let midnight = NSDate.combineDateWithTime(interestPeriod!.StartDate.dateByAddingDays(day) , time: NSDate(string: "00:00", formatString: "HH:mm"))
                        let startDate = NSDate.combineDateWithTime(interestPeriod!.StartDate.dateByAddingDays(day) , time: workingDayStartTime)
                        let midnightToStart = DTTimePeriod(startDate: midnight, endDate: startDate)
                        periods.append(midnightToStart)
                        
                        // go from workday endtime to midnight
                        let workdayEnd = NSDate.combineDateWithTime(interestPeriod!.StartDate.dateByAddingDays(day) , time: workingDayEndTime)
                        let nearlyMidnight = NSDate.combineDateWithTime(interestPeriod!.StartDate.dateByAddingDays(day) , time: NSDate(string: "23:59", formatString: "HH:mm"))
                        let endToMidnight = DTTimePeriod(startDate: workdayEnd, endDate: nearlyMidnight)
                        periods.append(endToMidnight)
                    }
                    
                    if lunchBreakEnabled == true {
                        let lunchStart =  NSDate.combineDateWithTime(interestPeriod!.StartDate.dateByAddingDays(day) , time: lunchBreakStartTime)
                        let lunchEnd =  NSDate.combineDateWithTime(interestPeriod!.StartDate.dateByAddingDays(day) , time: lunchBreakEndTime)
                        let lunch =  DTTimePeriod(startDate: lunchStart, endDate: lunchEnd)
                        periods.append(lunch)
                    }
                }
            }
            
            return periods
        }
        
        set {
            self.avoidPeriods = newValue   // For testing only
        }
    }
    
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        static let workingDayStartTime = "workingDayStartTime"
        static let workingDayEndTime = "workingDayEndTime"
        static let workingDayEnabled = "workingDayEnabled"
        static let lunchBreakStartTime = "lunchBreakStartTime"
        static let lunchBreakEndTime = "lunchBreakEndTime"
        static let lunchBreakEnabled = "lunchBreakEnabled"
        static let enabledDays = "enabledDays"
    }
    
    required init?(coder aDecoder: NSCoder) {
        workingDayStartTime = aDecoder.decodeObjectForKey("workingDayStartTime") as! NSDate
        workingDayEndTime = aDecoder.decodeObjectForKey("workingDayEndTime") as! NSDate
        workingDayEnabled = aDecoder.decodeObjectForKey("workingDayEnabled") as! Bool
        lunchBreakStartTime = aDecoder.decodeObjectForKey("lunchBreakStartTime") as! NSDate
        lunchBreakEndTime = aDecoder.decodeObjectForKey("lunchBreakEndTime") as! NSDate
        lunchBreakEnabled = aDecoder.decodeObjectForKey("lunchBreakEnabled") as! Bool
        enabledDays = aDecoder.decodeObjectForKey("enabledDays") as! Dictionary
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(workingDayStartTime, forKey:"workingDayStartTime")
        aCoder.encodeObject(workingDayEndTime, forKey:"workingDayEndTime")
        aCoder.encodeObject(workingDayEnabled, forKey:"workingDayEnabled")
        aCoder.encodeObject(lunchBreakStartTime, forKey:"lunchBreakStartTime")
        aCoder.encodeObject(lunchBreakEndTime, forKey:"lunchBreakEndTime")
        aCoder.encodeObject(lunchBreakEnabled, forKey:"lunchBreakEnabled")
        aCoder.encodeObject(enabledDays, forKey:"enabledDays")
    }
    
    
}