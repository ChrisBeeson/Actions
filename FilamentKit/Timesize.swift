//
//  Timesize.swift
//  Filament
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
        case .Second: return self.amount
        case .Minute: return self.amount*60
        case .Hour: return  self.amount*60*60
        case .Day: return self.amount*60*60*24
        case .Week: return self.amount*60*60*24*7
        case .Month: return self.amount*60*60*24*7*(365/12)
        case .Year:return self.amount*60*60*24*7*52
        }
    }
    
    //MARK:NSCoding
    
    required  init?(coder aDecoder: NSCoder) {
        unit = DTTimePeriodSize(rawValue: UInt(aDecoder.decodeIntegerForKey("unit")))!
        amount = aDecoder.decodeIntegerForKey("amount")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(Int(unit.rawValue), forKey: "unit")
        aCoder.encodeInteger(amount, forKey: "amount")
    }
    
    //MARK:NSCopying
    
    func copyWithZone(zone: NSZone) -> AnyObject  {
        return Timesize(unit:self.unit, amount:self.amount)
    }
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        self.unit = map["timeSizeUnit"].valueOrFail()
        self.amount = map["timeSizeAmount"].valueOrFail()
    }
    
    func mapping(map: Map) {
        unit                <- (map["timeSizeUnit"], EnumTransform())
        amount              <- map["timeSizeAmount"]
    }
}