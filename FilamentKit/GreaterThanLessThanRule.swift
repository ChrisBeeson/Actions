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
    var greaterThan = TimeSize(unit: .Hour, amount: 1)
    var lessThan = TimeSize(unit: .Hour, amount: 2)
    
    override init() {
        super.init()
    }
    
    // Rule output
    
    override var eventStartTimeWindow: DTTimePeriod? { get {
        guard inputDate != nil else { return nil }
        
        switch timeDirection {
        case .Forward:
            let startTime = inputDate!.dateByAddTimeSize(greaterThan)
            let endTime = inputDate!.dateByAddTimeSize(lessThan)
            let window = DTTimePeriod(startDate: startTime, endDate: endTime)
            //print("GreaterThanLessThan createdThisStartWindow : \(window.log())")
            return window
            
        case .Backward:
            let startTime = inputDate!.dateBySubtractingTimeSize(greaterThan)
            let endTime = inputDate!.dateBySubtractingTimeSize(lessThan)
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
            let startTime = inputDate!.dateByAddTimeSize(greaterThan)
            let endTime = inputDate!.dateByAddTimeSize(lessThan)
            
            var seconds = startTime.secondsEarlierThan(endTime)
            seconds = seconds / 2
            return startTime.dateByAddingSeconds(Int(seconds))
            
        case .Backward:
            let startTime = inputDate!.dateBySubtractingTimeSize(greaterThan)
            let endTime = inputDate!.dateBySubtractingTimeSize(lessThan)
            
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
        greaterThan = aDecoder.decodeObjectForKey(SerializationKeys.greaterThan) as! TimeSize
        lessThan = aDecoder.decodeObjectForKey(SerializationKeys.lessThan) as! TimeSize
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(greaterThan, forKey:SerializationKeys.greaterThan)
        aCoder.encodeObject(lessThan, forKey:SerializationKeys.lessThan)
    }
}