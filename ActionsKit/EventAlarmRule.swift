//
//  Alarm.swift
//  Actions
//
//  Created by Chris on 29/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import EventKit

enum AlarmType : Int {
    case None = 0
    case Message
    case Email
    //case MessageWithSound
}

enum AlarmOffset : Int {
    case OnDate = 0
    case MinutesBefore
    case HoursBefore
    case DaysBefore
}

class EventAlarmRule : Rule {
    
    override var name: String { return "RULE_NAME_ALARM".localized}
    override var availableToNodeType: NodeType { return [.Action] }
    
    var alarmType : AlarmType = .Message
    var alarmOffsetUnit : AlarmOffset = .OnDate
    var offsetAmount : Int = 1
    var emailAddress : String = ""
    
    override init() {
        super.init()
    }
    
    func makeAlarm() -> EKAlarm {
        
        var alarm = EKAlarm()
        
        return alarm
    }
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        static let alarmType = "alarmType"
        static let alarmOffsetUnit = "alarmOffsetUnit"
        static let offsetAmount = "offsetAmount"
        static let emailAddress = "emailAddress"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        alarmType = AlarmType(rawValue: aDecoder.decodeIntegerForKey(SerializationKeys.alarmType))!
        alarmOffsetUnit = AlarmOffset(rawValue: aDecoder.decodeIntegerForKey(SerializationKeys.alarmOffsetUnit))!
        offsetAmount = aDecoder.decodeIntegerForKey(SerializationKeys.offsetAmount)
        emailAddress = aDecoder.decodeObjectForKey(SerializationKeys.emailAddress) as! String
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(alarmType.rawValue, forKey:SerializationKeys.alarmType)
        aCoder.encodeInteger(alarmOffsetUnit.rawValue, forKey:SerializationKeys.alarmOffsetUnit)
        aCoder.encodeInteger(offsetAmount, forKey:SerializationKeys.offsetAmount)
        aCoder.encodeObject(emailAddress, forKey:SerializationKeys.emailAddress)
    }
    
    
    // MARK: NSCopying
    
    override func copyWithZone(zone: NSZone) -> AnyObject  {  //TODO: NSCopy
        let clone = EventAlarmRule()
        clone.alarmType = self.alarmType
        clone.alarmOffsetUnit = self.alarmOffsetUnit
        clone.offsetAmount = self.offsetAmount
        clone.emailAddress = self.emailAddress
        return clone
    }
    
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        alarmType <- (map[SerializationKeys.alarmType], EnumTransform())
        alarmOffsetUnit <- (map[SerializationKeys.alarmOffsetUnit], EnumTransform())
        offsetAmount <- map[SerializationKeys.offsetAmount]
        emailAddress <- map[SerializationKeys.emailAddress]
    }
}