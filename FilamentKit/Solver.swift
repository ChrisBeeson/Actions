//
//  Solver.swift
//  Filament
//
//  Created by Chris Beeson on 16/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import EventKit
import DateTools


/*

Window 1                       |----------------------------------|     <- can be only within this period
prefered time                              ^


Window 2                 |-------------------|

Action Dur Max           |---------|

Action Dur Min           |--|



Cal avoiding          |------------|            |---|   |----|

Timeslot found                         |----|
                                       ^^^^^^
*/


public class Solver {
    
    public class func calculateEventPeriod(inputDate: NSDate, rules:[Rule]) -> (solved: Bool, period:DTTimePeriod?) {
        
        var averageStartWindow: DTTimePeriod?
        var preferedStartTime: NSDate?
        var averageMaxDuration: TimeSize?
        var averageMinDuration: TimeSize?
        var preferedDuration: TimeSize?
        let avoidPeriods = DTTimePeriodCollection()
        
        
        // Step 1. Average out / Combine all the rules
        
        for var rule in rules {
        
            rule.inputDate = inputDate
            
            // Average event durations
            
            if let maxDur = rule.eventMaxDuration {
                if averageMaxDuration != nil {
                    if maxDur.inSeconds() < averageMaxDuration!.inSeconds() {averageMaxDuration = maxDur }
                } else { averageMaxDuration = maxDur }
            }
            
            if let minDur = rule.eventMaxDuration {
                if averageMinDuration != nil { if minDur.inSeconds() < averageMinDuration!.inSeconds() { averageMinDuration = minDur }
                } else { averageMinDuration = minDur }
            }
            
             // Average startTimeWindow
            
            if let ruleWindow = rule.eventStartTimeWindow {
                if averageStartWindow != nil {
                    if ruleWindow.StartDate.secondsLaterThan(averageStartWindow!.StartDate) > 0 { averageStartWindow!.StartDate = ruleWindow.StartDate }
                    if ruleWindow.EndDate.secondsEarlierThan(averageStartWindow!.EndDate) > 0 { averageStartWindow!.EndDate = ruleWindow.EndDate }
                } else { averageStartWindow = ruleWindow }
            }
            
            //TODO: Average dates & durations
            
            if (rule.eventPreferedStartDate != nil) { preferedStartTime = rule.eventPreferedStartDate! }
            if (rule.eventPreferedStartDate != nil) { preferedDuration = rule.eventPreferedDuration }
            
            
            // Combine Avoid periods
            
            if rule.avoidPeriods != nil { for avoidPeriod in rule.avoidPeriods! { avoidPeriods.addTimePeriod(avoidPeriod) } }
         }
        
        
        //  Step 2. Invert the avoid periods to free times.
        
        avoidPeriods.flatten()
        
        var freePeriods = avoidPeriods.voidPeriods()
        
        if freePeriods == nil { freePeriods = DTTimePeriodCollection() }
        
        
        // Lets go the easy way first: does our preferred window fit into a free period?
        
        if preferedStartTime != nil && preferedDuration != nil {
        
            let endDate = preferedStartTime?.dateByAddTimeSize(preferedDuration!)
            let preferedPeriod = DTTimePeriod(startDate: preferedStartTime!, endDate: endDate)
            
            if let pref = freePeriods?.periodsIntersectedByPeriod(preferedPeriod) {
            
                if pref.count() == 1 { return (true, preferedPeriod) }  // Woot!
            }
        }
        
        
        
        // Ok so it's more complicated...
        
        // First, lets remove any periods that are less then Min duration (using the ave startDate in the start window)
        
        for (index, free) in freePeriods!.periods()!.enumerate() {
            
            if Int(free.durationInSeconds()) < averageMinDuration?.inSeconds() { freePeriods!.removeTimePeriodAtIndex(index) }
        }
        
        
        return (false,nil)
    }

    
    
    
    
    public func solveEvents(events:[Event], startDate:NSDate, avoidCalendars:[EKCalendar]?) -> (Bool) {
        
        var currentDate = startDate
        
        for (index, node) in events.enumerate() {
            
            switch postion(index, events:events) {
                
            case .StartingAction: break
                
                // Easy - just need to calc  it's duration
                
                //   var window = durationForNode(node:node)
                
            case .Transition: break
                
            case .Action: break
                
            case .EndingAction: break
                
                
            }
        }
        
        return false
    }
    

    
    public enum NodePostion: Int { case StartingAction = 0, Transition, Action, EndingAction }
    
    internal func postion(index: Int, events:[Event]) -> NodePostion {

        var result: NodePostion
    
        switch index {
            
        case 0:
            result = .StartingAction
            
        case let x where x == events.count-1:
            result = .EndingAction
            
        case let x where x.isEven():
            result = .Action
            
        default:
            result = .Transition
        }
        return result
    }
}

