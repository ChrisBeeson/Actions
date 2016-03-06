//
//  DurationRule.swift
//  Filament
//
//  Created by Chris on 11/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

 class TransitionDurationWithVariance: Rule, NSCoding {
    
    // This rule creates a window of available time for the event to sit in.
    // User specifies a time period, and can pick a variance size.
    // Eg Next event should happen in 5 hours, give or take 30mins
    
     override var name: String { return "RULE_NAME_DURATION_WITH_VARIANCE".localized }
     override var availableToNodeType: NodeType { return NodeType.Transition }
     override var conflictingRules: [Rule]? { return nil }
    
    // Rule user input
    
     var eventStartsInDuration = TimeSize(unit: .Hour, amount: 1)
     var variance = TimeSize(unit: .Minute, amount: 15)
    
   
     override init() {
        super.init()
    }

    // Rule output
    
     override var eventStartTimeWindow: DTTimePeriod? { get {
        
        if  inputDate != nil {
            
            return DTTimePeriod(startDate: eventPreferedStartDate!.dateBySubtractingTimeSize(variance), endDate: eventPreferedStartDate!.dateByAddTimeSize(variance))
            
        } else { return nil }
        
        }
    }
    
     override var eventPreferedStartDate: NSDate? { get {
        
        return inputDate?.dateByAddTimeSize(eventStartsInDuration)
        
        }
    }
    
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        static let eventStartsInDuration = "transitionDurationWithVariance"
        static let variance = "variance"
    }
    
     required init?(coder aDecoder: NSCoder) {
        eventStartsInDuration = aDecoder.decodeObjectForKey(SerializationKeys.eventStartsInDuration) as! TimeSize
        variance = aDecoder.decodeObjectForKey(SerializationKeys.variance) as! TimeSize
    }
    
     func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(eventStartsInDuration, forKey:SerializationKeys.eventStartsInDuration)
        aCoder.encodeObject(variance, forKey:SerializationKeys.variance)
    }
}