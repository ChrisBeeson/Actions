//
//  GreaterThanLessThan.swift
//  Filament
//
//  Created by Chris Beeson on 28/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

class GreaterThanLessThanRule : Rule {
    
    override var name: String { return "RULE_NAME_GREATER_LESS".localized }
    override var availableToNodeType: NodeType { return [.Transition] }
    
    // Defaults
    var greaterThan = Timesize(unit: .Hour, amount: 1)
    var lessThan = Timesize(unit: .Hour, amount: 2)
    
    override init() {
        super.init()
    }
    
    // Rule output
    
    override var eventStartTimeWindow: DTTimePeriod? { get {
        guard inputDate != nil else { return nil }
        
        switch timeDirection {
        case .Forward:
            let startTime = inputDate!.dateByAddingTimesize(greaterThan)
            let endTime = inputDate!.dateByAddingTimesize(lessThan)
            let window = DTTimePeriod(startDate: startTime, endDate: endTime)
            //print("GreaterThanLessThan createdThisStartWindow : \(window.log())")
            return window
            
        case .Backward:
            let startTime = inputDate!.dateBySubtractingTimesize(greaterThan)
            let endTime = inputDate!.dateBySubtractingTimesize(lessThan)
            let window = DTTimePeriod(startDate: startTime, endDate: endTime)
            //print("GreaterThanLessThan createdThisStartWindow : \(window.log())")
            return window
        }
        }
    }
    
    override var eventPreferedStartDate: NSDate? { get {
        guard inputDate != nil else { return nil }
        
        switch timeDirection {
        case .Forward:
            let startTime = inputDate!.dateByAddingTimesize(greaterThan)
            let endTime = inputDate!.dateByAddingTimesize(lessThan)
            
            var seconds = startTime.secondsEarlierThan(endTime)
            seconds = seconds / 2
            return startTime.dateByAddingSeconds(Int(seconds))
            
        case .Backward:
            let startTime = inputDate!.dateBySubtractingTimesize(greaterThan)
            let endTime = inputDate!.dateBySubtractingTimesize(lessThan)
            
            var seconds = startTime.secondsEarlierThan(endTime)
            seconds = seconds / 2
            return startTime.dateByAddingSeconds(Int(seconds))
        }
        }
    }
    
    private struct SerializationKeys {
        static let greaterThan = "greaterThan"
        static let lessThan = "lessThan"
    }
    
    required init?(coder aDecoder: NSCoder) {
        greaterThan = aDecoder.decodeObjectForKey(SerializationKeys.greaterThan) as! Timesize
        lessThan = aDecoder.decodeObjectForKey(SerializationKeys.lessThan) as! Timesize
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(greaterThan, forKey:SerializationKeys.greaterThan)
        aCoder.encodeObject(lessThan, forKey:SerializationKeys.lessThan)
    }
}