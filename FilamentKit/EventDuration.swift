//
//  EventDuration.swift
//  Filament
//
//  Created by Chris Beeson on 25/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

public struct EventDuration: RuleType {
    
    // This rule sits the duration of an event.
    // It allows the event to be shortened to a minimum duration if required.
    
    
    public var name: String { return "[<->]" }
    public var availableToNodeType:NodeType { return .Action}
    public var conflictingRules: [RuleType]? { return nil }
    
    public var inputDate: NSDate?
    
    public init(inputDate: NSDate) {
        
        self.inputDate = inputDate;
    }
    
    
    // Specific user controls
    
    public var duration = TimeSize(unit: .Minute, amount: 30)
    public var minDuration = TimeSize(unit: .Minute, amount: 15)
    
    
    // Rule protocol requirements
    
    public var eventStartTimeWindow: DTTimePeriod? { get { return nil } }
    
    public var eventPreferedStartDate: NSDate? { get { return nil } }
    
    
    public var eventMaxDuration: TimeSize? { get { return duration } }
    public var eventMinDuration: TimeSize? { get { return minDuration } }
    public var eventPreferedDuration: TimeSize? { get { return duration } }
    
    public var avoidPeriods: [DTTimePeriod]? { get { return nil } }
    
}
