//
//  WorkingWeekRule.swift
//  Filament
//
//  Created by Chris Beeson on 30/10/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

//TODO: Working Week

 class WorkingWeekRule: Rule {
    
    // This rule sits the duration of an event.
    // It allows the event to be shortened to a minimum duration if required.
    
     override var name: String { return "RULE_NAME_WORK_HOURS".localized }
     override var availableToNodeType:NodeType { return [.Generic] }
     override var conflictingRules: [Rule]? { return nil }
     override var options: RoleOptions { get { return RoleOptions.RequiresInterestWindow } }
    
    //custom
    
     var workingDay: DTTimePeriod?
     var breaks: [DTTimePeriod]?     //default lunch 12.30 -> 13.30
    
    override init() {
        super.init()
    }
    
    // MARK: NSCoding
    
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