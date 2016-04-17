//
//  Rule.swift
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools
import ObjectMapper

protocol RuleType {
    
    var name: String {get}
    var availableToNodeType: NodeType {get}
    var conflictingRules: [Rule]? {get}
    var options: RoleOptions { get }
    
    // Inputs
    var inputDate: NSDate? {get set}
    var timeDirection:TimeDirection { get set }
    var interestPeriod: DTTimePeriod? {get set}
    
    // Outputs
    var eventStartTimeWindow: DTTimePeriod? {get}
    var eventPreferedStartDate: NSDate? {get}
    var eventDuration: Timesize? {get}
    var eventMinDuration: Timesize? {get}
    
    // Interactions
    var avoidPeriods: [AvoidPeriod]? {get set}
    var previousPeriod: DTTimePeriod? {get set}
    
    // Post Solver
    var solvedPeriod: DTTimePeriod? {get set}
    func postSolverCodeBlock()
}


 public class Rule: NSObject, RuleType, NSCoding, NSCopying, MappableCluster {
    
    var name: String {get {return "Not set"} }
    var ruleClass: String { get { return self.className } set {}}
    var availableToNodeType: NodeType {get {return NodeType.Void} }
    var conflictingRules: [Rule]? {get {return nil} }
    var options: RoleOptions {get { return RoleOptions.None } }
    var inputDate: NSDate?
    var timeDirection = TimeDirection.Forward
    var interestPeriod: DTTimePeriod?
    var eventStartTimeWindow: DTTimePeriod? {get {return nil} }
    var eventPreferedStartDate: NSDate? {get {return nil} }
    var eventDuration: Timesize? { get { return nil } }
    var eventMinDuration: Timesize? { get { return nil } }
    var avoidPeriods: [AvoidPeriod]?
    var previousPeriod: DTTimePeriod?
    var solvedPeriod: DTTimePeriod?
    
    func postSolverCodeBlock() {}
    func preDeletionCodeBlock() {}
    
    override init() { super.init() }

    class func RegisteredRuleClasses() -> [Rule] {
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
    
    //MARK: NSCoding
    required public init?(coder aDecoder: NSCoder) { super.init()}
    public func encodeWithCoder(aCoder: NSCoder) {}

    // MARK: NSCopying
    public func copyWithZone(zone: NSZone) -> AnyObject  { fatalError() }
    
    //MARK: JSON Mapping
    required public init?(_ map: Map) {}
    
    public func mapping(map: Map) {
        ruleClass <- map["ruleClass"]
    }
    
    public static func objectForMapping(map: Map) -> Mappable? {
        
        if let type: String = map["ruleClass"].value() {
            switch type {
            case TransitionDurationWithVariance.className():
                return TransitionDurationWithVariance(map)
            case EventDurationWithMinimumDuration.className():
               return EventDurationWithMinimumDuration(map)
            case AvoidCalendarEventsRule.className():
                return AvoidCalendarEventsRule(map)
            case WorkingWeekRule.className():
                return WorkingWeekRule(map)
            case TransitionDurationBasedOnTravelTime.className():
                return TransitionDurationBasedOnTravelTime(map)
            case EventFixedStartAndEndDate.className():
                return EventFixedStartAndEndDate(map)
            case GreaterThanLessThanRule.className():
                return GreaterThanLessThanRule(map)
            case NextUnitRule.className():
                return NextUnitRule(map)
            case WaitForUserRule.className():
                return WaitForUserRule(map)
            case EventAlarmRule.className():
                return EventAlarmRule(map)
            default:
                return nil
            }
        }
        return nil
    }
}

struct RoleOptions : OptionSetType {
    
    let rawValue: Int
    init(rawValue:Int) { self.rawValue = rawValue }
    
    static let None = RoleOptions(rawValue: 1)
    static let RequiresInterestWindow = RoleOptions(rawValue: 2)
    static let RequiresPreviousPeriod = RoleOptions(rawValue: 4)
    static let RequiresSolvedPeriod = RoleOptions(rawValue: 8)
    static let HasPostSolverCodeBlock = RoleOptions(rawValue: 16)
}