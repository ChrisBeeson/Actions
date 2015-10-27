//
//  EventDuration.swift
//  Filament
//
//  Created by Chris Beeson on 25/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

public struct EventDuration: Rule {
    
    // This rule sits the duration of an event.
    // It allows the event to be shortened to a minimum duration if required.
    
    public var name: String { return "Event Duration" }
    public var availableToNodeType:NodeType { return .Action}
    public var conflictingRules: [Rule]? { return nil }
    public var inputDate: NSDate?
    
    
    // Specific user controls
    
    public var duration = TimeSize(unit: .Minute, amount: 30)
    public var minDuration = TimeSize(unit: .Minute, amount: 15)
    
    
    // Rule out values
    
    public var eventMinDuration: TimeSize? { get { return minDuration } }
    public var eventDuration: TimeSize? { get { return duration } }
}
