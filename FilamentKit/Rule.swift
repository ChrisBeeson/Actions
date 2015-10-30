//
//  Rule.swift
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2015 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

public protocol Rule {
    
    var name: String {get}
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
    
    var avoidPeriods: [DTTimePeriod]? {get}
}

extension Rule {
    
    public var name: String {get {return ""} }
    public var availableToNodeType:NodeType {get {return NodeType.All} }
    public var conflictingRules: [Rule]? {get {return nil} }
    public var options: RoleOptions {get { return RoleOptions.None } }
    
    public var interestPeriod: DTTimePeriod? { get { return nil }  set {}}
    
    public var eventStartTimeWindow: DTTimePeriod? {get {return nil} }
    public var eventPreferedStartDate: NSDate? {get {return nil} }
    public var eventDuration: TimeSize? { get { return nil } }
    public var eventMinDuration: TimeSize? { get { return nil } }
    public var avoidPeriods: [DTTimePeriod]? { get { return nil } }
}


public struct RoleOptions : OptionSetType {
    
    public init(rawValue:Int) {
        
        self.rawValue = rawValue
    }
    
    public let rawValue: Int
    
    static let None                    = RoleOptions(rawValue: 0)
    static let RequiresInterestWindow  = RoleOptions(rawValue: 1 << 0)
    //  static let SecondOption = RoleOptions(rawValue: 1 << 1)
    //  static let ThirdOption  = RoleOptions(rawValue: 1 << 2)
}

/*
let singleOption = MyOptions.FirstOption
let multipleOptions: MyOptions = [.FirstOption, .SecondOption]
if multipleOptions.contains(.SecondOption) {
print("multipleOptions has SecondOption")
}
let allOptions = MyOptions(rawValue: 7)
if allOptions.contains(.ThirdOption) {
print("allOptions has ThirdOption")
}
*/


public struct TimeSize {
    
    var unit: DTTimePeriodSize
    var amount: Int
    
    public init (unit:DTTimePeriodSize, amount:Int) {
        
        self.unit = unit
        self.amount = amount
    }
    
    public func inSeconds() -> Int {
        
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
}




