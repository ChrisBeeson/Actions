//
//  Timesize.swift
//  Actions
//
//  Created by Chris Beeson on 11/04/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools
import ObjectMapper

class Timesize: NSObject, NSCoding, Mappable  {
    
    var unit: DTTimePeriodSize
    var amount: Int
    
    init (unit:DTTimePeriodSize, amount:Int) {
        self.unit = unit
        self.amount = amount
        super.init()
    }
    
    func inSeconds() -> Int {
        switch unit {
        case .second: return self.amount
        case .minute: return self.amount*60
        case .hour: return  self.amount*60*60
        case .day: return self.amount*60*60*24
        case .week: return self.amount*60*60*24*7
        case .month: return self.amount*60*60*24*7*(365/12)
        case .year:return self.amount*60*60*24*7*52
        }
    }
    
    var unitString: String {
        switch unit {
        case .second: return "RULE_UNIT_SEC".localized
        case .minute: return "RULE_UNIT_MIN".localized
        case .hour: return  "RULE_UNIT_HOUR".localized
        case .day: return "RULE_UNIT_DAY".localized
        case .week: return "RULE_UNIT_WEEK".localized
        case .month: return "RULE_UNIT_MONTH".localized
        case .year:return "RULE_UNIT_YEAR".localized
        }
    }
    
    var detailString:String {
        return String("\(amount)\(unitString)")
    }
    
    
    //MARK:NSCoding
    
    required  init?(coder aDecoder: NSCoder) {
        unit = DTTimePeriodSize(rawValue: UInt(aDecoder.decodeInteger(forKey: "unit")))!
        amount = aDecoder.decodeInteger(forKey: "amount")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Int(unit.rawValue), forKey: "unit")
        aCoder.encode(amount, forKey: "amount")
    }
    
    //MARK:NSCopying
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject  {
        return Timesize(unit:self.unit, amount:self.amount)
    }
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        self.unit = map["timeSizeUnit"].valueOr(DTTimePeriodSize.Minute)
        self.amount = map["timeSizeAmount"].valueOr(30)
    }
    
    func mapping(_ map: Map) {
        unit                <- (map["timeSizeUnit"], EnumTransform())
        amount              <- map["timeSizeAmount"]
    }
}
