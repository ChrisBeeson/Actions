//
//  DurationRule.swift
//  Actions
//
//  Created by Chris on 11/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools
import ObjectMapper

class TransitionDurationWithVariance: Rule {
    
    // This rule creates a window of available time for the event to sit in.
    // User specifies a time period, and can pick a variance size.
    // Eg Next event should happen in 5 hours, give or take 30mins
    
    override var name: String { return "RULE_NAME_DURATION_WITH_VARIANCE".localized }
    override var availableToNodeType: NodeType { return [.Transition] }
    
    override init() {
        super.init()
    }
    
    // Rule user input
    
    var eventStartsInDuration = Timesize(unit: .Hour, amount: 1)
    var variance = Timesize(unit: .Minute, amount: 15)
    
    // Rule output
    
    override var eventStartTimeWindow: DTTimePeriod? { get {
        guard inputDate != nil else { return nil }
        
        let startWindow = DTTimePeriod(startDate: eventPreferedStartDate!.dateBySubtractingTimesize(variance),
                                       endDate: eventPreferedStartDate!.dateByAddingTimesize(variance))
        return startWindow
        }
    }
    
    override var eventPreferedStartDate: Date? { get {
        switch timeDirection {
        case .forward: return inputDate?.dateByAddingTimesize(eventStartsInDuration)
        case .backward: return inputDate?.dateBySubtractingTimesize(eventStartsInDuration)
        }
        }
    }
    
    override var detailName: String {
        return "\(eventStartsInDuration.detailString) ~\(variance.detailString)"
    }
    
    
    // MARK: NSCoding
    
    fileprivate struct SerializationKeys {
        static let eventStartsInDuration = "eventStartsInDuration"
        static let variance = "variance"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        eventStartsInDuration = aDecoder.decodeObjectForKey(SerializationKeys.eventStartsInDuration) as! Timesize
        variance = aDecoder.decodeObjectForKey(SerializationKeys.variance) as! Timesize
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encodeObject(eventStartsInDuration, forKey:SerializationKeys.eventStartsInDuration)
        aCoder.encodeObject(variance, forKey:SerializationKeys.variance)
    }
    
    // MARK: NSCopying
    
    override func copy(with zone: NSZone?) -> AnyObject  {
        let clone = TransitionDurationWithVariance()
        clone.eventStartsInDuration = self.eventStartsInDuration
        clone.variance = self.variance
        return clone
    }
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(_ map: Map) {
        super.mapping(map)
        eventStartsInDuration        <- map[SerializationKeys.eventStartsInDuration]
        variance                     <- map[SerializationKeys.variance]
    }
}
