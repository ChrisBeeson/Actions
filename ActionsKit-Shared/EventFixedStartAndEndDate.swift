//
//  EventFixedStartAndEndDate.swift
//  Actions
//
//  Created by Chris Beeson on 28/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import DateTools


class EventFixedStartAndEndDate : Rule {
    
    override var name: String { return "RULE_NAME_FIXED".localized }
    override var availableToNodeType: NodeType { return [.Action] }
    
    override init() {
        super.init()
    }
    
    var startDate: NSDate?
    var endDate: NSDate?
    var createdAutomatically = false
    
    override var eventStartTimeWindow: DTTimePeriod? {
        get {
            guard let startDate = startDate else { return nil }
            return DTTimePeriod(size:.Second , amount: 1, startingAt:startDate)
        }
    }
    
    override var eventPreferedStartDate: NSDate? { return startDate }
    
    override var eventDuration: Timesize? {
        guard startDate != nil && endDate != nil else { return nil }
        
        let seconds = endDate!.secondsFrom(startDate)
        return Timesize(unit: .Second, amount:Int(seconds))
    }
    
    override var eventMinDuration: Timesize? {
        get {
            return self.eventDuration
        }
    }
    
    override func preSolverCodeBlock(rules rules:[Rule]) -> [Rule] {
        if startDate != nil {
            var filteredRules = rules
            for rule in filteredRules {
                if rule is WaitForUserRule { continue }
                rule.inputDate = NSDate()   // Pump it with a dummy date to catch it!
                if rule.eventStartTimeWindow != nil { filteredRules.removeObject(rule) }
                if rule.eventPreferedStartDate != nil { filteredRules.removeObject(rule) }
                rule.inputDate = nil
            }
            return filteredRules
            
        } else {
            return rules
        }
    }
    
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        static let startDate = "fixedStartDate"
        static let endDate = "minDuration"
        static let createdAutomatically = "createdAutomatically"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        startDate = aDecoder.decodeObjectForKey(SerializationKeys.startDate) as? NSDate
        endDate = aDecoder.decodeObjectForKey(SerializationKeys.endDate) as? NSDate
        createdAutomatically = aDecoder.decodeBoolForKey(SerializationKeys.createdAutomatically)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(startDate, forKey:SerializationKeys.startDate)
         aCoder.encodeObject(endDate, forKey:SerializationKeys.endDate)
         aCoder.encodeBool(createdAutomatically, forKey:SerializationKeys.startDate)
    }
    
    
    // MARK: NSCopying
    
    override func copyWithZone(zone: NSZone) -> AnyObject  {  //TODO: NSCopy
        /*
         let clone = Sequence()
         clone.title = title.copy() as! String
         return clone
         */
        return self
    }
    
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        startDate <- (map[SerializationKeys.startDate], DateTransform())
        endDate <- (map[SerializationKeys.endDate], DateTransform())
        createdAutomatically <- map[SerializationKeys.createdAutomatically]
    }
}