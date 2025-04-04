//
//  GreaterThanLessThan.swift
//  Actions
//
//  Created by Chris Beeson on 28/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools
import ObjectMapper

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
        case .forward:
            let startTime = inputDate!.dateByAddingTimesize(greaterThan)
            let endTime = inputDate!.dateByAddingTimesize(lessThan)
            let window = DTTimePeriod(startDate: startTime, endDate: endTime)
            return window
            
        case .backward:
            let startTime = inputDate!.dateBySubtractingTimesize(greaterThan)
            let endTime = inputDate!.dateBySubtractingTimesize(lessThan)
            let window = DTTimePeriod(startDate: startTime, endDate: endTime)
            return window
        }
        }
    }
    
    override var eventPreferedStartDate: Date? { get {
        guard inputDate != nil else { return nil }
        
        switch timeDirection {
        case .forward:
            let startTime = inputDate!.dateByAddingTimesize(greaterThan)
            let endTime = inputDate!.dateByAddingTimesize(lessThan)
            
            var seconds = startTime.secondsEarlierThan(endTime)
            seconds = seconds / 2
            return startTime.dateByAddingSeconds(Int(seconds))
            
        case .backward:
            let startTime = inputDate!.dateBySubtractingTimesize(greaterThan)
            let endTime = inputDate!.dateBySubtractingTimesize(lessThan)
            
            var seconds = startTime.secondsEarlierThan(endTime)
            seconds = seconds / 2
            return startTime.dateByAddingSeconds(Int(seconds))
        }
        }
    }
    
    override var detailName: String {
        return ">\(greaterThan.detailString) <\(lessThan.detailString)"
    }
    
    // MARK: NSCoding
    
    fileprivate struct SerializationKeys {
        static let greaterThan = "greaterThan"
        static let lessThan = "lessThan"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        greaterThan = aDecoder.decodeObjectForKey(SerializationKeys.greaterThan) as! Timesize
        lessThan = aDecoder.decodeObjectForKey(SerializationKeys.lessThan) as! Timesize
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encodeObject(greaterThan, forKey:SerializationKeys.greaterThan)
        aCoder.encodeObject(lessThan, forKey:SerializationKeys.lessThan)
    }
    
    
    // MARK: NSCopying
    
    override func copy(with zone: NSZone?) -> AnyObject  {  //TODO: NSCopy
        let clone = GreaterThanLessThanRule()
        clone.greaterThan = self.greaterThan
        clone.lessThan = self.lessThan
        return clone
        
    }
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(_ map: Map) {
        super.mapping(map)
        greaterThan             <- map[SerializationKeys.greaterThan]
        lessThan                <- map[SerializationKeys.lessThan]
    }
    
    //TODO: NSCopy
}
