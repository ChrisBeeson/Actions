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
    
    //defaults
    var greaterThan = TimeSize(unit: .Hour, amount: 1)
    var lessThan = TimeSize(unit: .Hour, amount: 2)
    
    override init() {
        super.init()
    }
    
    //TODO: Starttime window!!!
    
    // Rule output
    
    override var eventStartTimeWindow: DTTimePeriod? { get {
        if  inputDate != nil {
            let startTime = inputDate!.dateByAddTimeSize(greaterThan)
            let endTime = inputDate!.dateByAddTimeSize(lessThan)
            return DTTimePeriod(startDate: startTime, endDate: endTime)
        } else {
            return nil
        }
    }
    }

    override var eventPreferedStartDate: NSDate? { get {
        
        // Sits in the middle
        
        // return inputDate?.dateByAddTimeSize(eventStartsInDuration)
         return nil
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