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
    
    public func calcuateEventPeriod(startingDate: NSDate, rules:[Rule]) -> (solved: Bool, period:DTTimePeriod?) {
        
        var averageStartWindow: DTTimePeriod?
        var preferedStartTime: NSDate?
        var averageMaxDuration: TimeSize?
        var averageMinDuration: TimeSize?
        var preferedDuration: TimeSize?
        var avoidPeriods = [DTTimePeriod]()
        
        
        // Step 1. Average out all the rules
        
        for var rule in rules {
        
            rule.inputDate = startingDate
            
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
            if (rule.eventPreferedStartDate != nil) {preferedDuration = rule.eventPreferedDuration }
            
            
            // Avoid periods
            
            if rule.avoidPeriods != nil { for avoidPeriod in rule.avoidPeriods! { avoidPeriods.append (avoidPeriod) } }
         }
        
        
        //
        
        
        // Step 2. Convert all avoid periods into a collection
        
        //let avoids = DTTimePeriodCollection().addPeriods(avoidPeriods)
        
        
        // Step 3. See if prefered Start-time and duration does not insect with any avoid periods.  If it doesn't Great!  Thats it.
        
        
        
        /*
        let perferedPeriod = DTTimePeriod(size: preferedDuration, startingAt: preferedStartTime)
        var collidingperiods = avoids.periodsInside(preferedPeriod)
        
        if collidingperiods.count == 0  { return (true, preferedPeriod) }
        */
        
        
        
        // Lets find out what periods are free...
        
        
        // DTTimePeriodCollection.voidPeriods
        
        
        
        // Remove periods that are two small, or out of our window.
        
        // Then find the period that is closest to our perfered startdate.
        
        
        
        
        
        
        
        // Step 4. Else Switch through - trying to solve simple issues, such as if it was 10 mins later it would fit without intercepting..
        
        // Step 4. Doesn't fit around the prefered time at all.. Find the closest hole to fit it in from the preferred Start time, working from the beginning of the window.
        
        
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

