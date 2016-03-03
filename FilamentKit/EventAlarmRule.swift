//
//  Alarm.swift
//  Filament
//
//  Created by Chris on 29/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class EventAlarmRule : Rule {
    
    override var name: String { return "RULE_NAME_ALARM".localized}
    
    override init() {
        super.init()
    }
    
    private struct SerializationKeys {
        // static let duration = "duration"
        //   static let minDuration = "minDuration"
    }
    
    required init?(coder aDecoder: NSCoder) {
        //   calendars = aDecoder.decodeObjectForKey("calendars") as! [EKCalendar]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        //aCoder.encodeObject(calendars, forKey:"calendars")
    }
}