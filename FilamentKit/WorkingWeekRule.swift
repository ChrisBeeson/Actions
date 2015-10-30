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

public class WorkingWeekRule: NSObject, Rule {
    
    // This rule sits the duration of an event.
    // It allows the event to be shortened to a minimum duration if required.
    
    public var name: String { return "!!!" }
    public var availableToNodeType:NodeType { return .None}
    public var conflictingRules: [Rule]? { return nil }
    public var options: RoleOptions { get { return RoleOptions.RequiresInterestWindow } }
    
    // Rule inputs
    public var inputDate: NSDate?
    public var interestPeriod: DTTimePeriod?
    
    //custom
    
    public var workingDay: DTTimePeriod?
    public var breaks: [DTTimePeriod]?     //default lunch 12.30 -> 13.30
    
}