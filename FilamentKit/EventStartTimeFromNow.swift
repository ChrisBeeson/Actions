//
//  DurationRule.swift
//  Filament
//
//  Created by Chris on 11/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

public struct EventStartTimeFromNow: RuleType {
    
    // This rule creates a window of available time for the event to sit in.
    // User specifies a time period, and can pick a variance size.
    // Eg Next event should happen in 5 hours, give or take 30mins


    public var name: String { return "~>" }
    public var availableToNodeType:NodeType { return NodeType.Transition }
    public var conflictingRules: [RuleType]? { return nil }
    
    public var inputDate: NSDate?
    
    public init(inputDate: NSDate) {
        
        self.inputDate = inputDate;
    }
    

    // Specific user controls
    
    public var duration = TimeSize(unit: .Minute, amount: 30)
    public var variance = TimeSize(unit: .Hour, amount: 1)
    

    // Rule protocol requirements
    
    public var eventStartTimeWindow: DTTimePeriod? { get {
        
        let window = DTTimePeriod(startDate: inputDate, endDate: inputDate)
        
        window.lengthenWithAnchorDate(DTTimePeriodAnchor.Center, size: variance.unit, amount: variance.amount*2)
        
        return window
        
        }
    }
    
    public var eventPreferedStartDate: NSDate? { get {
        
        return inputDate?.dateByAddTimeSize(duration)
        
        }
    }
    
    public var eventMaxDuration: TimeSize? { get { return nil } }
    public var eventMinDuration: TimeSize? { get { return nil } }
    public var eventPreferedDuration: TimeSize? { get { return nil } }
    public var avoidPeriods: [DTTimePeriod]? { get { return nil } }
}