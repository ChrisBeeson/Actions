//
//  Solver.swift
//  Filament
//
//  Created by Chris Beeson on 16/09/2015.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import EventKit
import DateTools

/*

Window 1                       |-----------------|     <- Event can be only within this period
prefered start time                    ^
Action Dur Max                         |--------------|
Action Dur Min                         |--|
AvoidPeriods          |------------|         |---|   |----|

                                       |----|

Timeslot found                         ^^^^^^

------------------------------------------------------------------------------------------------
-- Rules
------------------------------------------------------------------------------------------------

Start time of the solved period MUST fall within the averageStartWindow

*/

typealias SolvedPeriod = (solved: Bool, period:DTTimePeriod?)


class Solver: NSObject {
    
    class func calculateEventPeriod(inputDate: NSDate, node: Node, rules:[Rule]) -> SolvedPeriod {
        
        func printDebug(string: String) { if true == true { print(string) } }
        
        /*
            This solving class works only on action Nodes.  But it need the transition based rules added to it.
            Whether this a massive architecture flaw I'm not sure.
            Transition rules generate a startWindow based on the inputdate.
            The action node supplies rules to create it's duration.
        */
        
        var averageStartWindow: DTTimePeriod?
        var preferedStartTime: NSDate?
        var averageDuration: TimeSize?
        var averageMinDuration: TimeSize?
        let avoidPeriods = DTTimePeriodCollection()

        //////////////////////////////////////////////////////////////////////////
        ///  Phase 1: 
        ///  Average out and/or combine all the rules
        //////////////////////////////////////////////////////////////////////////
        
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
            //there should normally only be one of each.
            
            if (rule.eventPreferedStartDate != nil) { preferedStartTime = rule.eventPreferedStartDate! }
            if (rule.eventDuration != nil) { averageDuration = rule.eventDuration }
        }
        
        
        //////////////////////////////////////////////////////////////////////////
        ///  Phase 2: 
        ///  Make sure we meet the Basic Requirements
        //////////////////////////////////////////////////////////////////////////
        
        if preferedStartTime == nil  || averageMinDuration == nil || averageStartWindow == nil || averageDuration == nil {
            printDebug("! Solver failed to meet basic requirements")
            return (false,nil)
        }
        

        //////////////////////////////////////////////////////////////////////////
        ///  Phase 4: 
        ///  Create window of interest and update any rules that need it
        //////////////////////////////////////////////////////////////////////////
        
        let windowOfinterest = DTTimePeriod(startDate: averageStartWindow!.StartDate!, endDate: averageStartWindow!.EndDate!.dateByAddTimeSize(averageDuration!))
       
        //printDebug("Window of interest \(windowOfinterest)")
        
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
        
        
        //////////////////////////////////////////////////////////////////////////
        ///  Phase 5: 
        ///  Flatten & Invert the avoid periods. 
        ///  (Create free periods from the gaps inbetween)
        //////////////////////////////////////////////////////////////////////////
        
        avoidPeriods.flatten()
        let freePeriods = avoidPeriods.voidPeriods(windowOfinterest)
        
        let preferedPeriod = DTTimePeriod(startDate: preferedStartTime!, endDate: preferedStartTime?.dateByAddTimeSize(averageDuration!))
        
        //printDebug("Free Period: \(freePeriods[0].StartDate!),\(freePeriods[0].StartDate!), \(freePeriods[0].EndDate!)")
        //printDebug("Preferred Period:,\(preferedPeriod.StartDate), \(preferedPeriod.EndDate!)")
        
        
        //////////////////////////////////////////////////////////////////////////
        ///  Phase 6: 
        ///  The Main Algorithm
        //////////////////////////////////////////////////////////////////////////
        printDebug("\n\n--------------------------------------------------")
        printDebug("----- Node: \(node.title)")
        printDebug("--------------------------------------------------")
        printDebug("Prefered Period: \(preferedPeriod.log())")
        printDebug("Start Window: \(averageStartWindow?.log())")
        printDebug("Avoid periods: \(avoidPeriods.debugDescription)")
        printDebug("--------------------------------------------------")
        
        if freePeriods.periods() == nil {
            printDebug("Failed: There are no Free Periods")
            return (false, nil)
        }
        
        // does the corrent node have an event, with a timePeriod that fits into a free Period?
        
        /*
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
        */
        
        // no? lets find the best period
        var bestPeriod: DTTimePeriod?
        
        for free in freePeriods.periods()! {
            
            // Lets evaluate this free period
            printDebug("--------- Processing New Free Period  ---------")
            
            printDebug("StartWindow Relation to free period: \(averageStartWindow!.relationToPeriod(free).rawValue)")
            
            /*
            if averageStartWindow!.relationToPeriod(free) != DTTimePeriodRelation.Inside {
                print("Free period not related to Average Start window, so skipping")
                continue
            }
            */
            
            /*
            if averageStartWindow!.relationToPeriod(free) == DTTimePeriodRelation.Inside || averageStartWindow!.relationToPeriod(free) == DTTimePeriodRelation.After {
                print("Free period not related to Average Start window, so skipping")
                continue
            }
            */
            
            // Does our preferred window fit into this free period?
            if preferedPeriod.relationToPeriod(free) == DTTimePeriodRelation.Inside ||
                preferedPeriod.relationToPeriod(free) == DTTimePeriodRelation.ExactMatch {
                
                printDebug("SOLVED: PreferedPeriod fits")
                return (true, preferedPeriod)
            }
            
            // create a possible period
            
            var possiblePeriod: DTTimePeriod?
            
            // ok so the free period is wider than the min spec.
            // is it eariler (left) or after (right)? the prefered date...
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
                        printDebug("Poss period cancelled because Dur: \(posDur)  avgMinDur:\(avgMinDur)")
                        possiblePeriod = nil
                    }
                }
            }
            
            // no possible period
            if possiblePeriod == nil { continue }
            
            // we have a possible period
            printDebug("Found Possible Period: \(possiblePeriod?.log())")
            
            if bestPeriod == nil { bestPeriod = possiblePeriod; continue }
            
            // compare with the best Period as see if this is closer to the startTime.
            let possDistToStart =  abs(possiblePeriod!.StartDate.secondsFrom(preferedPeriod.StartDate))
            let bestDistToStart = abs(bestPeriod!.StartDate.secondsFrom(preferedPeriod.StartDate))
            if possDistToStart < bestDistToStart { bestPeriod = possiblePeriod }
            
            // remove this period from free Periods..
        }
        
        
        if bestPeriod != nil { printDebug("Found Best Period: \(bestPeriod?.log())"); return (true, bestPeriod) }
        else { printDebug("Failed to solve"); return (false,nil) }
    }
}


extension DTTimePeriod {
public func log() ->String {
    let startTime = self.StartDate.formattedDateWithFormat("hh:mm")
    let endTime = self.StartDate.formattedDateWithFormat("hh:mm")
    return("\(startTime) -> \(endTime)")
}
}


