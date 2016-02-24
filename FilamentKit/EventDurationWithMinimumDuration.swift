//
//  EventDuration.swift
//  Filament
//
//  Created by Chris Beeson on 25/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

 class EventDurationWithMinimumDuration : Rule, NSCoding  {
    
    // This rule sits the duration of an event.
    // It allows the event to be shortened to a minimum duration if required.
    
     override var name: String { return "Min Duration" }
     override var availableToNodeType:NodeType { return .Action}
     override var conflictingRules: [Rule]? { return nil }
    
     override init() {
        super.init()
    }
    
    // Specific user controls
    
     var duration = TimeSize(unit: .Minute, amount: 30)
     var minDuration = TimeSize(unit: .Minute, amount: 15)
    
    
    // Rule out values
    
     override var eventMinDuration: TimeSize? { get { return minDuration } }
     override var eventDuration: TimeSize? { get { return duration } }
    
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        static let duration = "duration"
        static let minDuration = "minDuration"
    }
    
     required init?(coder aDecoder: NSCoder) {
        
        duration = aDecoder.decodeObjectForKey(SerializationKeys.duration) as! TimeSize
        minDuration = aDecoder.decodeObjectForKey(SerializationKeys.minDuration) as! TimeSize
    }
    
     func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(duration, forKey:SerializationKeys.duration)
        aCoder.encodeObject(minDuration, forKey:SerializationKeys.minDuration)
    }
}
