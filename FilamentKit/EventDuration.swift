//
//  EventDuration.swift
//  Filament
//
//  Created by Chris Beeson on 25/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

public class EventDuration: Rule, NSCoding  {
    
    // This rule sits the duration of an event.
    // It allows the event to be shortened to a minimum duration if required.
    
    public override var name: String { return "Event Duration" }
    public override var availableToNodeType:NodeType { return .Action}
    public override var conflictingRules: [Rule]? { return nil }
    
    public override init() {
        super.init()
    }
    
    // Specific user controls
    
    public var duration = TimeSize(unit: .Minute, amount: 30)
    public var minDuration = TimeSize(unit: .Minute, amount: 15)
    
    
    // Rule out values
    
    public override var eventMinDuration: TimeSize? { get { return minDuration } }
    public override var eventDuration: TimeSize? { get { return duration } }
    
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        static let duration = "duration"
        static let minDuration = "minDuration"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        duration = aDecoder.decodeObjectForKey(SerializationKeys.duration) as! TimeSize
        minDuration = aDecoder.decodeObjectForKey(SerializationKeys.minDuration) as! TimeSize
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(duration, forKey:SerializationKeys.duration)
        aCoder.encodeObject(minDuration, forKey:SerializationKeys.minDuration)
    }
}
