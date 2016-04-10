//
//  WorkingWeekRule.swift
//  Filament
//
//  Created by Chris Beeson on 30/10/2015.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools
import ObjectMapper

class WorkingWeekRule: Rule {
    
    // This rule sets the duration of an event.
    // It allows the event to be shortened to a minimum duration if required.
    
    override var name: String { return "RULE_NAME_WORK_HOURS".localized }
    override var availableToNodeType:NodeType { return [.Generic] }
    override var conflictingRules: [Rule]? { return nil }
    override var options: RoleOptions { get { return RoleOptions.RequiresInterestWindow } }
    
    var workingDayStartTime =  NSDate(string: "09:00", formatString: "HH:mm")
    var workingDayEndTime = NSDate(string: "17:30", formatString: "HH:mm")
    var workingDayEnabled = true
    var lunchBreakStartTime = NSDate(string: "12:30", formatString: "HH:mm")
    var lunchBreakEndTime = NSDate(string: "13:30", formatString: "HH:mm")
    var lunchBreakEnabled = true
    var enabledDays = [2:true, 3:true, 4:true, 5:true, 6:true, 7:false, 1:false]  // Sunday = 1
    
    override init() { super.init() }
    
    override var avoidPeriods: [AvoidPeriod]? {
        get {
            if interestPeriod == nil { return nil }
            var numberOfDays = interestPeriod?.EndDate.daysLaterThan(interestPeriod?.StartDate)
            numberOfDays! += 1
            var periods = [AvoidPeriod]()
            
            for day in 0...numberOfDays! {
                let dayNumber = interestPeriod!.StartDate.dateByAddingDays(day).weekday()
                if enabledDays[dayNumber] == true {
                    
                    if workingDayEnabled == true {
                        // go from midnight to the working day start Time
                        let midnight = NSDate.combineDateWithTime(interestPeriod!.StartDate.dateByAddingDays(day) , time: NSDate(string: "00:00", formatString: "HH:mm"))
                        let startDate = NSDate.combineDateWithTime(interestPeriod!.StartDate.dateByAddingDays(day) , time: workingDayStartTime)
                        //  startDate = startDate.dateBySubtractingMinutes(1)
                        let midnightToStart = DTTimePeriod(startDate: midnight, endDate: startDate)
                        let avoidPeriod1 = AvoidPeriod(period: midnightToStart, type: .WorkingWeekMorning, object: nil)
                        periods.append(avoidPeriod1)
                        
                        // go from workday endtime to midnight
                        let workdayEnd = NSDate.combineDateWithTime(interestPeriod!.StartDate.dateByAddingDays(day) , time: workingDayEndTime)
                        let nearlyMidnight = NSDate.combineDateWithTime(interestPeriod!.StartDate.dateByAddingDays(day) , time: NSDate(string: "23:59", formatString: "HH:mm"))
                        let endToMidnight = DTTimePeriod(startDate: workdayEnd, endDate: nearlyMidnight)
                        let avoidPeriod2 = AvoidPeriod(period: endToMidnight, type: .WorkingWeekEvening, object: nil)
                        periods.append(avoidPeriod2)
                    }
                    
                    if lunchBreakEnabled == true {
                        let lunchStart = NSDate.combineDateWithTime(interestPeriod!.StartDate.dateByAddingDays(day) , time: lunchBreakStartTime)
                        let lunchEnd = NSDate.combineDateWithTime(interestPeriod!.StartDate.dateByAddingDays(day) , time: lunchBreakEndTime)
                        // lunchEnd = lunchEnd.dateBySubtractingMinutes(1)
                        let lunch = DTTimePeriod(startDate: lunchStart, endDate: lunchEnd)
                        let avoidPeriod1 = AvoidPeriod(period: lunch, type: .WorkingWeekLunch, object: nil)
                        periods.append(avoidPeriod1)
                    }
                } else {
                    
                    // the day isn't enabled - there for we must have the day off - and so we avoid it all
                    let midnight = NSDate.combineDateWithTime(interestPeriod!.StartDate.dateByAddingDays(day) , time: NSDate(string: "00:00", formatString: "HH:mm"))
                    let nearlyMidnight = NSDate.combineDateWithTime(interestPeriod!.StartDate.dateByAddingDays(day) , time: NSDate(string: "23:59", formatString: "HH:mm"))
                    let dayOff = DTTimePeriod(startDate: midnight, endDate: nearlyMidnight)
                    let avoidPeriod = AvoidPeriod(period: dayOff, type: .WorkingWeekDayOff, object: nil)
                    periods.append(avoidPeriod)
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
        super.init(coder:aDecoder)
        workingDayStartTime = aDecoder.decodeObjectForKey("workingDayStartTime") as! NSDate
        workingDayEndTime = aDecoder.decodeObjectForKey("workingDayEndTime") as! NSDate
        workingDayEnabled = aDecoder.decodeObjectForKey("workingDayEnabled") as! Bool
        lunchBreakStartTime = aDecoder.decodeObjectForKey("lunchBreakStartTime") as! NSDate
        lunchBreakEndTime = aDecoder.decodeObjectForKey("lunchBreakEndTime") as! NSDate
        lunchBreakEnabled = aDecoder.decodeObjectForKey("lunchBreakEnabled") as! Bool
        enabledDays = aDecoder.decodeObjectForKey("enabledDays") as! Dictionary
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(workingDayStartTime, forKey:"workingDayStartTime")
        aCoder.encodeObject(workingDayEndTime, forKey:"workingDayEndTime")
        aCoder.encodeObject(workingDayEnabled, forKey:"workingDayEnabled")
        aCoder.encodeObject(lunchBreakStartTime, forKey:"lunchBreakStartTime")
        aCoder.encodeObject(lunchBreakEndTime, forKey:"lunchBreakEndTime")
        aCoder.encodeObject(lunchBreakEnabled, forKey:"lunchBreakEnabled")
        aCoder.encodeObject(enabledDays, forKey:"enabledDays")
    }
    
    // MARK: NSCopying
    
    override func copyWithZone(zone: NSZone) -> AnyObject  {
        let clone = WorkingWeekRule()
        clone.workingDayStartTime = self.workingDayStartTime
        clone.workingDayEndTime = self.workingDayEndTime
        clone.workingDayEnabled = self.workingDayEnabled
        clone.lunchBreakStartTime =  self.lunchBreakStartTime
        clone.lunchBreakEndTime = self.lunchBreakEndTime
        clone.lunchBreakEnabled = self.lunchBreakEnabled
        clone.enabledDays = self.enabledDays
        return clone
    }
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        workingDayStartTime      <- (map[SerializationKeys.workingDayStartTime],DateTransform())
        workingDayEndTime        <- (map[SerializationKeys.workingDayEndTime],DateTransform())
        workingDayEnabled        <- map[SerializationKeys.workingDayEnabled]
        lunchBreakStartTime      <- (map[SerializationKeys.lunchBreakStartTime],DateTransform())
        lunchBreakEndTime        <- (map[SerializationKeys.lunchBreakEndTime],DateTransform())
        lunchBreakEnabled        <- map[SerializationKeys.lunchBreakEnabled]
        enabledDays              <- map[SerializationKeys.enabledDays]
    }
}