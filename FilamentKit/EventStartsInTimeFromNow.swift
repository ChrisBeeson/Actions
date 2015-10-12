//
//  DurationRule.swift
//  Filament
//
//  Created by Chris on 11/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

public struct EventStartsInTimeFromNow: Rule {
    
    // This rule creates a window of available time for the event to sit in.
    // User specifies a time period, and can pick a variance size.
    // Eg Next event should happen in 5 hours, give or take 30mins
    
    public var name: String { return "~>" }
    public var availableToNodeType:NodeType { return NodeType.Transition }
    public var conflictingRules: [Rule]? { return nil }
    
    public var inputDate: NSDate?
    
    
    // Specific user controls
    // Default: Event starts in 1 hour, give or take 15 min
    
    public var eventStartsInDuration = TimeSize(unit: .Hour, amount: 1)
    public var variance = TimeSize(unit: .Minute, amount: 15)
    
    
    // Rule protocol requirements
    
    public var eventStartTimeWindow: DTTimePeriod? { get {
        
        if  inputDate != nil {
            
            return DTTimePeriod(startDate: eventPreferedStartDate!.dateBySubtractingTimeSize(variance), endDate: eventPreferedStartDate!.dateByAddTimeSize(variance))
            
        } else { return nil }
        
        }
    }
    
    public var eventPreferedStartDate: NSDate? { get {
        
        return inputDate?.dateByAddTimeSize(eventStartsInDuration)
        
        }
    }
}