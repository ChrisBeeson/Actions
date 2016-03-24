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
    var availableToNodeType: NodeType {get}
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

public class Rule: NSObject, RuleType {
    
     var name: String {get {return "Not set"} }
     var Description: String {get {return "NOT SET"} }
     var availableToNodeType: NodeType {get {return NodeType.Void} }
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
        ruleClasses.append(AvoidCalendarEventsRule())
        ruleClasses.append(WorkingWeekRule())
        ruleClasses.append(TransitionDurationBasedOnTravelTime())
        ruleClasses.append(EventFixedStartAndEndDate())
        ruleClasses.append(GreaterThanLessThanRule())
        ruleClasses.append(NextUnitRule())
        ruleClasses.append(WaitForUserRule())
        ruleClasses.append(EventAlarmRule())
        return ruleClasses
    }
}


struct RoleOptions : OptionSetType {
    
    let rawValue: Int
    init(rawValue:Int) { self.rawValue = rawValue }

    static let None = RoleOptions(rawValue: 1)
    static let RequiresInterestWindow = RoleOptions(rawValue: 2)
}



