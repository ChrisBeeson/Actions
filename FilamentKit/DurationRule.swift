//
//  DurationRule.swift
//  Filament
//
//  Created by Chris on 11/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

public class DurationRule: Rule {
    
    override public var name: String { return "Duration" }
    
    override public var availableToNodeType:Node.NodeType { return .All }
    
    override public var conflictingRules: [Rule]? { return nil }
    
    
    ///
    /// Duration Rule
    ///
    
    public var duration: Int = 1
    public var durationUnit: Unit = .Hours
    
    public var variance: Int = 30
    public var varianceUnit: Unit = .Minutes
    
    public enum Unit: Int {
        
        case Minutes,Hours, Days, Weeks, Months
    }


    override public func runRule(startDate: NSDate, nextRuleToSatisfy:Rule, calendersToAvoid:[AnyObject]?) -> (valid:Bool, endDate:NSDate?) {
        
        let potentalEndTime = addDurationToDate(startDate, duration:duration, unit:durationUnit)
        
        return (true,potentalEndTime)
    }
    
    
    private func addDurationToDate(startDate:NSDate, duration:Int, unit:Unit) -> NSDate  {
        
        switch unit {
            
            case .Minutes: return startDate.dateByAddingMinutes(duration)
            case .Hours: return startDate.dateByAddingHours(duration)
            case .Days: return startDate.dateByAddingDays(duration)
            case .Weeks: return startDate.dateByAddingWeeks(duration)
            case .Months: return startDate.dateByAddingMonths(duration)
        }
      
    }
}