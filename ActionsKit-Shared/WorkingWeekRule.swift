//
//  WorkingWeekRule.swift
//  Actions
//
//  Created by Chris Beeson on 30/10/2015.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools
import ObjectMapper

class WorkingWeekRule: Rule {
    
    override var name: String { return "RULE_NAME_WORK_HOURS".localized }
    override var availableToNodeType:NodeType { return [.Generic] }
    override var options: RoleOptions { get { return RoleOptions.RequiresInterestWindow } }
    
    // Defaults
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
            var numberOfDays = interestPeriod?.endDate.daysLaterThan(interestPeriod?.startDate)
            numberOfDays! += 1
            var periods = [AvoidPeriod]()
            
            for day in 0...numberOfDays! {
                let dayNumber = interestPeriod!.startDate.addingDays(day).weekday()
                
                if enabledDays[dayNumber] == true {
                    
                    if workingDayEnabled == true {
                        
                        // midnight to the working day start Time
                        let midnight = Date.combineDateWithTime(interestPeriod!.startDate.addingDays(day) , time: NSDate(string: "00:00", formatString: "HH:mm"))
                        let startDate = Date.combineDateWithTime(interestPeriod!.startDate.addingDays(day) , time: workingDayStartTime)
                        let midnightToStart = DTTimePeriod(start: midnight, end: startDate)
                        let avoidPeriod1 = AvoidPeriod(period: midnightToStart, type: .workingWeekMorning, object: nil)
                        periods.append(avoidPeriod1)
                        
                        // workday endtime to midnight
                        let workdayEnd = Date.combineDateWithTime(interestPeriod!.startDate.addingDays(day) , time: workingDayEndTime)
                        let nearlyMidnight = Date.combineDateWithTime(interestPeriod!.startDate.addingDays(day) , time: NSDate(string: "23:59", formatString: "HH:mm"))
                        let endToMidnight = DTTimePeriod(start: workdayEnd, end: nearlyMidnight)
                        let avoidPeriod2 = AvoidPeriod(period: endToMidnight, type: .workingWeekEvening, object: nil)
                        periods.append(avoidPeriod2)
                    }
                    
                    if lunchBreakEnabled == true {
                        
                        let lunchStart = Date.combineDateWithTime(interestPeriod!.startDate.addingDays(day) , time: lunchBreakStartTime)
                        let lunchEnd = Date.combineDateWithTime(interestPeriod!.startDate.addingDays(day) , time: lunchBreakEndTime)
                        let lunch = DTTimePeriod(start: lunchStart, end: lunchEnd)
                        let avoidPeriod1 = AvoidPeriod(period: lunch, type: .workingWeekLunch, object: nil)
                        periods.append(avoidPeriod1)
                    }
                } else {
                    
                    // the day isn't enabled therefore we must have the day off - so avoid it all
                    let midnight = Date.combineDateWithTime(interestPeriod!.startDate.addingDays(day) , time: NSDate(string: "00:00", formatString: "HH:mm"))
                    let nearlyMidnight = Date.combineDateWithTime(interestPeriod!.startDate.addingDays(day) , time: NSDate(string: "23:59", formatString: "HH:mm"))
                    let dayOff = DTTimePeriod(start: midnight, end: nearlyMidnight)
                    let avoidPeriod = AvoidPeriod(period: dayOff, type: .workingWeekDayOff, object: nil)
                    periods.append(avoidPeriod)
                }
            }
            return periods
        }
        set {
            self.avoidPeriods = newValue   // For testing only
        }
    }
    
    // MARK: - Storage -
    
    // MARK: NSCoding
    
    fileprivate struct SerializationKeys {
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
        workingDayStartTime = aDecoder.decodeObject(forKey: "workingDayStartTime") as! Date
        workingDayEndTime = aDecoder.decodeObject(forKey: "workingDayEndTime") as! Date
        workingDayEnabled = aDecoder.decodeObject(forKey: "workingDayEnabled") as! Bool
        lunchBreakStartTime = aDecoder.decodeObject(forKey: "lunchBreakStartTime") as! Date
        lunchBreakEndTime = aDecoder.decodeObject(forKey: "lunchBreakEndTime") as! Date
        lunchBreakEnabled = aDecoder.decodeObject(forKey: "lunchBreakEnabled") as! Bool
        enabledDays = aDecoder.decodeObject(forKey: "enabledDays") as! Dictionary
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(workingDayStartTime, forKey:"workingDayStartTime")
        aCoder.encode(workingDayEndTime, forKey:"workingDayEndTime")
        aCoder.encode(workingDayEnabled, forKey:"workingDayEnabled")
        aCoder.encode(lunchBreakStartTime, forKey:"lunchBreakStartTime")
        aCoder.encode(lunchBreakEndTime, forKey:"lunchBreakEndTime")
        aCoder.encode(lunchBreakEnabled, forKey:"lunchBreakEnabled")
        aCoder.encode(enabledDays, forKey:"enabledDays")
    }
    
    // MARK: NSCopying
    
    override func copy(with zone: NSZone?) -> AnyObject  {
        let clone = WorkingWeekRule()
        clone.workingDayStartTime = self.workingDayStartTime
        clone.workingDayEndTime = self.workingDayEndTime
        clone.workingDayEnabled = self.workingDayEnabled
        clone.lunchBreakStartTime = self.lunchBreakStartTime
        clone.lunchBreakEndTime = self.lunchBreakEndTime
        clone.lunchBreakEnabled = self.lunchBreakEnabled
        clone.enabledDays = self.enabledDays
        return clone
    }
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(_ map: Map) {
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
