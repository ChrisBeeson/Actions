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
import DateTools

enum AlarmType : Int {
    case none = 0
    case message
    case email
    //case MessageWithSound
}

enum AlarmOffset : Int {
    case onDate = 0
    case minutesBefore
    case hoursBefore
    case daysBefore
}

class EventAlarmRule : Rule {
    
    override var name: String { return "RULE_NAME_ALARM".localized}
    override var availableToNodeType: NodeType { return [.Action] }
    
    var alarmType : AlarmType = .message
    var alarmOffsetUnit : AlarmOffset = .onDate
    var offsetAmount : Int = 1
    var emailAddress : String = ""
    
    override init() {
        super.init()
    }
    
    func makeAlarm() -> EKAlarm? {
        guard alarmType != .none else { return nil }
        var offset: Double
        switch alarmOffsetUnit {
            case .onDate: offset = 0
            case .minutesBefore: offset = Double(Timesize(unit: DTTimePeriodSize.Minute , amount: offsetAmount).inSeconds())
            case .hoursBefore: offset = Double(Timesize(unit: DTTimePeriodSize.Minute , amount: offsetAmount).inSeconds())
            case .daysBefore: offset = Double(Timesize(unit: DTTimePeriodSize.Hour , amount: offsetAmount).inSeconds())
        }
        
        let alarm = EKAlarm(relativeOffset: (0 - offset))
        
        if emailAddress.isEmpty == false {
            alarm.emailAddress = emailAddress
        } else {
            alarm.soundName = "Hero"
        }
        return alarm
    }
    
    // MARK: NSCoding
    
    fileprivate struct SerializationKeys {
        static let alarmType = "alarmType"
        static let alarmOffsetUnit = "alarmOffsetUnit"
        static let offsetAmount = "offsetAmount"
        static let emailAddress = "emailAddress"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        alarmType = AlarmType(rawValue: aDecoder.decodeInteger(forKey: SerializationKeys.alarmType))!
        alarmOffsetUnit = AlarmOffset(rawValue: aDecoder.decodeInteger(forKey: SerializationKeys.alarmOffsetUnit))!
        offsetAmount = aDecoder.decodeInteger(forKey: SerializationKeys.offsetAmount)
        emailAddress = aDecoder.decodeObject(forKey: SerializationKeys.emailAddress) as! String
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(alarmType.rawValue, forKey:SerializationKeys.alarmType)
        aCoder.encode(alarmOffsetUnit.rawValue, forKey:SerializationKeys.alarmOffsetUnit)
        aCoder.encode(offsetAmount, forKey:SerializationKeys.offsetAmount)
        aCoder.encode(emailAddress, forKey:SerializationKeys.emailAddress)
    }
    
    
    // MARK: NSCopying
    
    override func copy(with zone: NSZone?) -> AnyObject  {  //TODO: NSCopy
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
    
    override func mapping(_ map: Map) {
        super.mapping(map)
        alarmType <- (map[SerializationKeys.alarmType], EnumTransform())
        alarmOffsetUnit <- (map[SerializationKeys.alarmOffsetUnit], EnumTransform())
        offsetAmount <- map[SerializationKeys.offsetAmount]
        emailAddress <- map[SerializationKeys.emailAddress]
    }
}
