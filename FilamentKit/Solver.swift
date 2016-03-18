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

Window 1                       |----------------------------------|     <- Event can be only within this period
prefered time                              ^
Window 2                 |-------------------|
Action Dur Max           |---------|
Action Dur Min           |--|
Cal avoiding          |------------|            |---|   |----|
|----|
Timeslot found                         ^^^^^^

*/

typealias SolvedPeriod = (solved: Bool, period:DTTimePeriod?)

class Solver {
    
    class func calculateEventPeriod(inputDate: NSDate, node: Node, rules:[Rule]) -> SolvedPeriod {
        
        var averageStartWindow: DTTimePeriod?
        var preferedStartTime: NSDate?
        var averageDuration: TimeSize?
        var averageMinDuration: TimeSize?
        let avoidPeriods = DTTimePeriodCollection()
        
        // Step 1. Average out / Combine all the rules
        
        // first average out all start and duration
        
        for rule in rules {
            
            rule.inputDate = inputDate
            
            // Average event durations
            
            if let dur = rule.eventDuration {
                if averageDuration != nil {
                    if dur.inSeconds() < averageDuration!.inSeconds() {averageDuration = dur }
                } else { averageDuration = dur }
            }
            
            if let minDur = rule.eventMinDuration {
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
            
            //TODO: Properly average dates & durations
            
            if (rule.eventPreferedStartDate != nil) { preferedStartTime = rule.eventPreferedStartDate! }
            if (rule.eventDuration != nil) { averageDuration = rule.eventDuration }
        }
        
        // Step 2. Make sure we have the Basic Requirements
        
        if preferedStartTime == nil  || averageMinDuration == nil || averageStartWindow == nil || averageDuration == nil {
            //print("! Solver failed to meet basic requirements")
            return (false,nil)
        }
        
        // Find the window of interest, and then go through all the rules again and see if theres any avoids.
        
        let windowOfinterest = DTTimePeriod(startDate: averageStartWindow!.StartDate!, endDate: averageStartWindow!.EndDate!.dateByAddTimeSize(averageDuration!))
        
        for rule in rules {
            
            if rule.options.contains(RoleOptions.RequiresInterestWindow) {
                rule.interestPeriod = windowOfinterest
            }
            
            // Combine Avoid periods
            
            if rule.avoidPeriods != nil {
                for avoidPeriod in rule.avoidPeriods! {
                    avoidPeriods.addTimePeriod(avoidPeriod)
                }
            }
        }
        
        
        //  Step 3. Invert the avoid periods to free times
        
        avoidPeriods.flatten()
        
        let freePeriods = avoidPeriods.voidPeriods(windowOfinterest)
        let preferedPeriod = DTTimePeriod(startDate: preferedStartTime!, endDate: preferedStartTime?.dateByAddTimeSize(averageDuration!))
        
        //print("Free Period: \(freePeriods[0].StartDate!)",freePeriods[0].StartDate!, freePeriods[0].EndDate!)
        //print("Preferred Period:",preferedPeriod.StartDate, preferedPeriod.EndDate!)
        
        
        // The Main Algorithm
        
        //print("\n\n--------------------------------------------------")
        //print("prefered Period: \(preferedPeriod.debugDescription)")
        //print("average Start Window: \(averageStartWindow.debugDescription)")
        //print("avoid periods: \(avoidPeriods.debugDescription)")
        //print("--------------------------------------------------")
        
        if freePeriods.periods() == nil {
            return (false, nil)
        }
        
        // does the corrent node have an event, with a timePeriod that fits into a free Period?
        if node.event != nil {
            for free in freePeriods.periods()! {
                let relation = node.event!.timePeriod().relationToPeriod(free) as DTTimePeriodRelation
                switch relation {
                case .ExactMatch, .Inside:
                    return (true, node.event!.timePeriod())
                default:break
                }
            }
        }
        
        // no? lets find the best period
        var bestPeriod: DTTimePeriod?
        
        for free in freePeriods.periods()! {
            
            // Lets evaluate this free period
            
            // Does our preferred window fit into this free period?
            if preferedPeriod.relationToPeriod(free) == DTTimePeriodRelation.Inside || preferedPeriod.relationToPeriod(free) == DTTimePeriodRelation.ExactMatch {
                
                //print("SOLVED: PreferedPeriod fits \n")
                return (true, preferedPeriod)
            }
            
            // ok so the free period is wider than the min spec.
            // is it eariler (left) or after (right)? the prefered date...
            
            var possiblePeriod: DTTimePeriod?
            
            //  after (right) the prefered date...
            if  free.StartDate.isLaterThanOrEqualTo(preferedPeriod.StartDate) {
                
                possiblePeriod = DTTimePeriod()
                possiblePeriod!.StartDate = free.StartDate!
                
                let freeDurSecs = abs(free.StartDate.secondsFrom(free.EndDate))
                
                if freeDurSecs >= preferedPeriod.durationInSeconds()  {
                    possiblePeriod!.EndDate = free.StartDate.dateByAddingSeconds(Int(preferedPeriod.durationInSeconds()))
                } else {
                    possiblePeriod!.EndDate = free.EndDate!
                    
                    // does it longer than min Dur?
                    let possDur = Int(possiblePeriod!.durationInSeconds())
                    let avgMinDur = averageMinDuration!.inSeconds()
                    if possDur < avgMinDur { possiblePeriod = nil }
                }
            }
            
            // or left
            
            if possiblePeriod == nil && free.StartDate.isEarlierThan(preferedPeriod.StartDate) {
                possiblePeriod = DTTimePeriod()
                
                // lets back date it
                possiblePeriod!.EndDate = free.EndDate!
                
                let freeDurSecs = abs(free.StartDate.secondsFrom(free.EndDate))
                if freeDurSecs >= preferedPeriod.durationInSeconds()  {
                    possiblePeriod!.StartDate = free.EndDate.dateBySubtractingSeconds(Int(preferedPeriod.durationInSeconds()))
                    
                } else {
                    possiblePeriod!.StartDate = free.StartDate!
                    let posDur = Int(possiblePeriod!.durationInSeconds())
                    let avgMinDur = averageMinDuration!.inSeconds()
                    
                    if  posDur < avgMinDur {
                        //print("Poss period cancelled because Dur: \(posDur)  avgMinDur:\(avgMinDur)")
                        possiblePeriod = nil
                    }
                }
            }
            
            if possiblePeriod == nil { continue }
            
            //print("! Found Possible Period: \(possiblePeriod)")
            
            if bestPeriod == nil { bestPeriod = possiblePeriod; continue }
            
            // compare with the best Period as see if this is closer to the startTime.
            
            let possDistToStart =  abs(possiblePeriod!.StartDate.secondsFrom(preferedPeriod.StartDate))
            let bestDistToStart = abs(bestPeriod!.StartDate.secondsFrom(preferedPeriod.StartDate))
            if possDistToStart < bestDistToStart { bestPeriod = possiblePeriod }
            
            // remove this period from free Periods..
        }
        if bestPeriod != nil { return (true, bestPeriod) }
        else { return (false,nil) }
    }
}

