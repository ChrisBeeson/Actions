//
//  NextUnitRule.swift
//  Actions
//
//  Created by Chris Beeson on 28/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools
import ObjectMapper

enum NextPreferedTimeType: Int {
    case morning = 0
    case afternoon
    case evening
    case night
    case anytime
    case sametime
    case twoHours
}

enum NextUnitType: Int {
    case day = 0
    case week
    case month
    case year
    
    var unitString: String {
        switch self {
        case .day: return "RULE_UNIT_DAY".localized
        case .week: return "RULE_UNIT_WEEK".localized
        case .month: return "RULE_UNIT_MONTH".localized
        case .year:return "RULE_UNIT_YEAR".localized
        }
    }
}

class NextUnitRule : Rule {
    
    //TODO: MAKE AVAL TO BACKWARDS
    
    override var name: String { return "RULE_NAME_NEXT".localized }
    override var availableToNodeType: NodeType { return [.Transition] }
    override var options: RoleOptions { return [.RequiresPreviousPeriod] }
    
    override init() {
        super.init()
    }
    
    var unit = NextUnitType.day
    var amount = 1
    var preferedTime = NextPreferedTimeType.anytime
    
    
    // Rule output
    
    override var eventStartTimeWindow: DTTimePeriod? { get {
        guard inputDate != nil else { return nil }
        
        let date = calcDate()
        let period = timePeriod(preferedTime)
        
        // combine the dates and times
        let startDate = Date.combineDateWithTime(date, time: period.period.startDate!)
        let endDate = Date.combineDateWithTime(date, time: period.period.endDate!)
        return DTTimePeriod(start: startDate, end: endDate)
        }
    }
    
    override var eventPreferedStartDate: Date? { get {
        guard inputDate != nil else { return nil }
        let date = calcDate()
        let time = timePeriod(preferedTime).preferedStartDate
        return (Date.combineDateWithTime(date, time: time))
        }
    }
    
    
    //MARK: Internal Processing
    
    func timePeriod(_ timeType:NextPreferedTimeType) -> (period:DTTimePeriod, preferedStartDate:Date) {
        guard previousPeriod != nil else { fatalError() }
        
        switch preferedTime {
        case .morning:
            let period = DTTimePeriod(start: NSDate(string: "06:00", formatString:"hh:mm") as Date!,
                                      end: NSDate(string: "12:00", formatString:"hh:mm") as Date!)
            return (period!, NSDate(string: "09:00", formatString: "hh:mm") as Date)
            
        case .afternoon:
            let period = DTTimePeriod(start: NSDate(string: "12:00", formatString:"hh:mm") as Date!,
                                      end: NSDate(string: "18:00", formatString:"HH:mm") as Date!)
            return (period!, NSDate(string: "13:00", formatString: "HH:mm") as Date)
            
        case .evening:
            let period = DTTimePeriod(start: NSDate(string: "18:00", formatString:"HH:mm") as Date!,
                                      end: NSDate(string: "23:59", formatString:"HH:mm") as Date!)
            return (period!, NSDate(string: "18:00", formatString: "HH:mm") as Date)
            
        case .night:
            let period = DTTimePeriod(start: NSDate(string: "00:00", formatString:"hh:mm") as Date!,
                                      end: NSDate(string: "06:00", formatString:"hh:mm") as Date!)
            return (period! ,NSDate(string: "01:00", formatString: "hh:mm") as Date)
            
        case .sametime:
            // TODO: get the startTime from the previous node.
            let startTime = previousPeriod!.startDate
            let period = DTTimePeriod(start: startTime!, end:(startTime! as NSDate).addingMinutes(1))
            return (period!, startTime!)
            
        case .anytime:
            let period = DTTimePeriod(start: NSDate(string: "00:00", formatString: "hh:mm") as Date!,
                                      end: NSDate(string: "23:59", formatString: "HH:mm") as Date!)
            return (period!, NSDate(string: "10:00", formatString: "hh:mm") as Date)
            
        case .twoHours:
            // TODO: get the startTime from the previous node.
            let startTime = previousPeriod!.startDate
            let period = DTTimePeriod(start: (startTime! as NSDate).subtractingHours(2), end: (startTime! as NSDate).addingHours(2))
            return (period!, startTime!)
        }
    }
    
    func calcDate() -> Date {
        //FIXME: lots of fatalErrors() here
        guard let periodUnit = DTTimePeriodSize(rawValue:UInt(unit.rawValue+3)) else { fatalError() }
        let timesize = Timesize(unit: periodUnit, amount: amount)
        guard let date = inputDate?.dateByAddingTimesize(timesize)  else { fatalError() }
        return date
    }
    
    override var detailName: String {
        if amount > 1 {
            return "Next \(amount) \(self.unit.unitString)s"
        } else {
            return "Next \(unit.unitString)"
        }
    }
    
    // MARK: NSCoding
    
    fileprivate struct SerializationKeys {
        static let unit = "unit"
        static let amount = "amount"
        static let preferedTime = "preferedTime"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        unit = NextUnitType(rawValue: aDecoder.decodeInteger(forKey: SerializationKeys.unit))!
        amount = aDecoder.decodeInteger(forKey: SerializationKeys.amount)
        preferedTime = NextPreferedTimeType(rawValue: aDecoder.decodeInteger(forKey: SerializationKeys.preferedTime))!
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(unit.rawValue, forKey:SerializationKeys.unit)
        aCoder.encode(amount, forKey:SerializationKeys.amount)
        aCoder.encode(preferedTime.rawValue, forKey:SerializationKeys.preferedTime)
    }
    
    // MARK: NSCopying
    
    override func copy(with zone: NSZone?) -> AnyObject  {
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
    
    override func mapping(_ map: Map) {
        super.mapping(map)
        unit             <- (map[SerializationKeys.unit], EnumTransform())
        amount           <- map[SerializationKeys.amount]
        preferedTime     <- (map[SerializationKeys.preferedTime], EnumTransform())
    }
}
