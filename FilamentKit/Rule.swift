//
//  Rule.swift
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2015 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

protocol RuleType {
    
    var name: String {get}
    var description: String {get}
    var availableToNodeType:NodeType {get}
    var conflictingRules: [Rule]? {get}
    var options: RoleOptions { get }
    
    // Inputs
    
    var inputDate: NSDate? {get set}
    var interestPeriod: DTTimePeriod? {get set}
    
    // Outputs
    
    var eventStartTimeWindow: DTTimePeriod? {get}
    var eventPreferedStartDate: NSDate? {get}
    var eventDuration: TimeSize? {get}
    var eventMinDuration: TimeSize? {get}
    
    var avoidPeriods: [DTTimePeriod]? {get set}
    

}

class Rule: NSObject, RuleType {
    
     var name: String {get {return "Not set"} }
     var Description: String {get {return "NOT SET"} }
     var availableToNodeType:NodeType {get {return NodeType.All} }
     var conflictingRules: [Rule]? {get {return nil} }
     var options: RoleOptions {get { return RoleOptions.None } }
     var inputDate: NSDate?
     var interestPeriod: DTTimePeriod?
     var eventStartTimeWindow: DTTimePeriod? {get {return nil} }
     var eventPreferedStartDate: NSDate? {get {return nil} }
     var eventDuration: TimeSize? { get { return nil } }
     var eventMinDuration: TimeSize? { get { return nil } }
     var avoidPeriods: [DTTimePeriod]?
    
    
    
    class func RuleClasses() -> [Rule] {
        
        var ruleClasses = [Rule]()
        ruleClasses.append(TransitionDurationWithVariance())
        ruleClasses.append(EventDurationWithMinimumDuration())
        ruleClasses.append(AvoidCalendarEvents())
        ruleClasses.append(WorkingWeekRule())
        ruleClasses.append(TransitionDurationBasedOnTravelTime())
        ruleClasses.append(EventFixedStartAndEndDate())
        ruleClasses.append(GreaterThanLessThan())
        ruleClasses.append(NextUnitRule())
        ruleClasses.append(WaitForUserRule())
        ruleClasses.append(EventAlarmRule())
        return ruleClasses
    }
}


 struct RoleOptions : OptionSetType {
    
     init(rawValue:Int) {
        
        self.rawValue = rawValue
    }
    
     let rawValue: Int
    
    static let None                    = RoleOptions(rawValue: 0)
    static let RequiresInterestWindow  = RoleOptions(rawValue: 1 << 0)
    //  static let SecondOption = RoleOptions(rawValue: 1 << 1)
    //  static let ThirdOption  = RoleOptions(rawValue: 1 << 2)
}



 class TimeSize: NSObject, NSCoding  {
    
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
    
    required  init?(coder aDecoder: NSCoder) {
        
        unit = DTTimePeriodSize(rawValue: UInt(aDecoder.decodeIntegerForKey("unit")))!
        amount = aDecoder.decodeIntegerForKey("amount")
    }
    
     func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeInteger(Int(unit.rawValue), forKey: "unit")
        aCoder.encodeInteger(amount, forKey: "amount")
    }
}




