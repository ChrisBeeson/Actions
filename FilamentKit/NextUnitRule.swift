//
//  NextUnitRule.swift
//  Filament
//
//  Created by Chris Beeson on 28/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools
import ObjectMapper

enum NextPreferedTimeType: Int {
    case Morning = 0
    case Afternoon
    case Evening
    case Night
    case Anytime
    case Sametime
    case TwoHours
}

enum NextUnitType: Int {
    case Day = 0
    case Week
    case Month
    case Year
}

class NextUnitRule : Rule {
    
    //TODO: MAKE AVAL TO BACKWARDS
    
    override var name: String { return "RULE_NAME_NEXT".localized }
    override var availableToNodeType: NodeType { return [.Transition] }
    override var options: RoleOptions { return [.RequiresPreviousPeriod] }
    
    override init() {
        super.init()
    }
    
    var unit = NextUnitType.Day
    var amount = 1
    var preferedTime = NextPreferedTimeType.Anytime
    
    
    // Rule output
    
    override var eventStartTimeWindow: DTTimePeriod? { get {
        guard inputDate != nil else { return nil }
        
        let date = calcDate()
        let period = timePeriod(preferedTime)
        
        // combine the dates and times
        let startDate = NSDate.combineDateWithTime(date, time: period.period.StartDate!)
        let endDate = NSDate.combineDateWithTime(date, time: period.period.EndDate!)
        return DTTimePeriod(startDate: startDate, endDate: endDate)
        }
    }
    
    override var eventPreferedStartDate: NSDate? { get {
        guard inputDate != nil else { return nil }
        let date = calcDate()
        let time = timePeriod(preferedTime).preferedStartDate
        return (NSDate.combineDateWithTime(date, time: time))
        }
    }
    
    
    //MARK: Internal Processing
    
    func timePeriod(timeType:NextPreferedTimeType) -> (period:DTTimePeriod, preferedStartDate:NSDate) {
        guard previousPeriod != nil else { fatalError() }
        
        switch preferedTime {
        case .Morning:
            let period = DTTimePeriod(startDate: NSDate(string: "06:00", formatString:"hh:mm"),
                                      endDate: NSDate(string: "12:00", formatString:"hh:mm"))
            return (period, NSDate(string: "09:00", formatString: "hh:mm"))
            
        case .Afternoon:
            let period = DTTimePeriod(startDate: NSDate(string: "12:00", formatString:"hh:mm"),
                                      endDate: NSDate(string: "18:00", formatString:"HH:mm"))
            return (period, NSDate(string: "13:00", formatString: "HH:mm"))
            
        case .Evening:
            let period = DTTimePeriod(startDate: NSDate(string: "18:00", formatString:"HH:mm"),
                                      endDate: NSDate(string: "23:59", formatString:"HH:mm"))
            return (period, NSDate(string: "18:00", formatString: "HH:mm"))
            
        case .Night:
            let period = DTTimePeriod(startDate: NSDate(string: "00:00", formatString:"hh:mm"),
                                      endDate: NSDate(string: "06:00", formatString:"hh:mm"))
            return (period ,NSDate(string: "01:00", formatString: "hh:mm"))
            
        case .Sametime:
            // TODO: get the startTime from the previous node.
            let startTime = previousPeriod!.StartDate
            let period = DTTimePeriod(startDate: startTime!, endDate:startTime!.dateByAddingMinutes(1))
            return (period, startTime!)
            
        case .Anytime:
            let period = DTTimePeriod(startDate: NSDate(string: "00:00", formatString: "hh:mm"),
                                      endDate: NSDate(string: "23:59", formatString: "HH:mm"))
            return (period, NSDate(string: "10:00", formatString: "hh:mm"))
            
        case .TwoHours:
            // TODO: get the startTime from the previous node.
            let startTime = previousPeriod!.StartDate
            let period = DTTimePeriod(startDate: startTime!.dateBySubtractingHours(2), endDate: startTime!.dateByAddingHours(2))
            return (period, startTime!)
        }
    }
    
    func calcDate() -> NSDate {
        //FIXME: lots of fatalErrors() here
        guard let periodUnit = DTTimePeriodSize(rawValue:UInt(unit.rawValue+3)) else { fatalError() }
        let timesize = Timesize(unit: periodUnit, amount: amount)
        guard let date = inputDate?.dateByAddingTimesize(timesize)  else { fatalError() }
        return date
    }
    
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        static let unit = "unit"
        static let amount = "amount"
        static let preferedTime = "preferedTime"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        unit = NextUnitType(rawValue: aDecoder.decodeIntegerForKey(SerializationKeys.unit))!
        amount = aDecoder.decodeIntegerForKey(SerializationKeys.amount)
        preferedTime = NextPreferedTimeType(rawValue: aDecoder.decodeIntegerForKey(SerializationKeys.preferedTime))!
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(unit.rawValue, forKey:SerializationKeys.unit)
        aCoder.encodeInteger(amount, forKey:SerializationKeys.amount)
        aCoder.encodeInteger(preferedTime.rawValue, forKey:SerializationKeys.preferedTime)
    }
    
    // MARK: NSCopying
    
    override func copyWithZone(zone: NSZone) -> AnyObject  {
        let clone = NextUnitRule()
        clone.unit = self.unit
        clone.amount = self.amount
        clone.preferedTime = self.preferedTime
        return clone
    }
    
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        unit             <- (map[SerializationKeys.unit], EnumTransform())
        amount           <- map[SerializationKeys.amount]
        preferedTime     <- (map[SerializationKeys.preferedTime], EnumTransform())
    }
}