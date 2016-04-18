//
//  EventDuration.swift
//  Filament
//
//  Created by Chris Beeson on 25/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools
import ObjectMapper

class EventDurationWithMinimumDuration : Rule  {
    
    // This rule sits the duration of an event.
    // It allows the event to be shortened to a minimum duration if required.
    
    override var name: String { return "RULE_NAME_DURATION_WITH_MIN".localized  }
    override var availableToNodeType: NodeType { return [.Action] }
    
    override init() {
        super.init()
        ruleClass = "eventDurationWithMinimumDuration"
    }
    
    // Specific user controls
    
    var duration = Timesize(unit: .Minute, amount: 30)
    var minDuration = Timesize(unit: .Minute, amount: 15)
    
    
    // Rule out values
    
    override var eventMinDuration: Timesize? { get { return minDuration } }
    override var eventDuration: Timesize? { get { return duration } }
    
    override var detailName: String {
        return "\(duration.detailString)  (-\(minDuration.detailString))"
    }
    
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        static let duration = "duration"
        static let minDuration = "minDuration"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        duration = aDecoder.decodeObjectForKey(SerializationKeys.duration) as! Timesize
        minDuration = aDecoder.decodeObjectForKey(SerializationKeys.minDuration) as! Timesize
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(duration, forKey:SerializationKeys.duration)
        aCoder.encodeObject(minDuration, forKey:SerializationKeys.minDuration)
    }
    
    
    // MARK: NSCopying
    
    override func copyWithZone(zone: NSZone) -> AnyObject  {
        let clone = EventDurationWithMinimumDuration()
        clone.duration = self.duration
        clone.minDuration = self.minDuration
        return clone
    }
    
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        ruleClass                     <- map["ruleClass"]
        duration        <- map[SerializationKeys.duration]
        minDuration     <- map[SerializationKeys.minDuration]
    }
}
