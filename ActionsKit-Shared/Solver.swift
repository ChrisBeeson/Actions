//
//  Solver.swift
//  Actions
//
//  Created by Chris Beeson on 16/09/2015.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import EventKit
import DateTools
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


/*
 
 Window 1                       |-----------------|     <- Event can be only within this period
 prefered start time                    ^
 Action Dur Max                         |--------------|
 Action Dur Min                         |--|
 AvoidPeriods          |------------|         |---|   |----|
 
                                        |----|
 
 Timeslot found                         ^^^^^^
 
 */

typealias SolvedPeriod = (solved: Bool, period:DTTimePeriod?, errors:[SolverError])

class Solver: NSObject {
    
    class func calculateEventPeriod(_ inputDate: Date, direction:TimeDirection, node: Node, rules:[Rule]) -> SolvedPeriod! {
        
        //TODO: Use rules attached to the node, and then add rules: as additional rules
        
        func printDebug(_ string: String) { if true == false { print(string) } }
        
        /*
         This solving class works only on action Nodes.  But it need the transition based rules added to it.
         Whether this a massive architecture flaw I'm not sure.
         Transition rules generate a startWindow based on the inputdate.
         The action node supplies rules to create it's duration.
         */
        
        var averageStartWindow: DTTimePeriod?
        var preferedStartTime: Date?
        var averageDuration: Timesize?
        var averageMinDuration: Timesize?
        var detailedAvoidPeriods = [AvoidPeriod]()
        var errors = [SolverError]()
        
        //////////////////////////////////////////////////////////////////////////
        ///  Phase 1:
        ///  Average out and/or combine all the rules
        //////////////////////////////////////////////////////////////////////////
        
        for rule in rules {
            
            rule.inputDate = inputDate
            rule.timeDirection = direction
            rule.owner = node
            
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
                    if ruleWindow.startDate.secondsLaterThan(averageStartWindow!.startDate) > 0 { averageStartWindow!.startDate = ruleWindow.startDate }
                    if ruleWindow.endDate.secondsEarlierThan(averageStartWindow!.endDate) > 0 { averageStartWindow!.endDate = ruleWindow.endDate }
                } else { averageStartWindow = ruleWindow }
            }
            
            //TODO: Properly average dates & durations
            //there should normally only be one of each.
            
            if (rule.eventPreferedStartDate != nil) { preferedStartTime = rule.eventPreferedStartDate! as Date }
            if (rule.eventDuration != nil) { averageDuration = rule.eventDuration }
        }
        
        
        //////////////////////////////////////////////////////////////////////////
        ///  Phase 2:
        ///  Make sure we meet the Basic Requirements
        //////////////////////////////////////////////////////////////////////////
        
    
        if averageMinDuration == nil || averageDuration == nil || preferedStartTime == nil || averageStartWindow == nil {
            errors.append(SolverError(errorLevel:.failed, error:.noFreePeriods, object:nil, node:node))
            return (false, nil, errors)
        }
        
        // if preferedStartTime == nil { preferedStartTime = inputDate }
        //if averageStartWindow == nil { averageStartWindow = DTTimePeriod(size: .Second, amount:1, startingAt: inputDate)}
        
        // if the averageStartWindow start and end dates are the same, offset the endDate by a second.
        if averageStartWindow!.startDate.isEqual(to: averageStartWindow!.endDate) {
            averageStartWindow!.endDate = averageStartWindow!.startDate.addingSeconds(1)
        }
        
        //Why??
        /*
        if averageStartWindow?.EndDate.isEarlierThan(averageStartWindow?.StartDate) == true {
            averageStartWindow = DTTimePeriod(startDate: averageStartWindow!.EndDate, endDate: averageStartWindow!.StartDate)
        }
        */
        
        //////////////////////////////////////////////////////////////////////////
        ///  Phase 3:
        ///  If we're running backwards then we need to subtract the ideal duration from everything
        //////////////////////////////////////////////////////////////////////////
        
        if direction == .backward {
            preferedStartTime = preferedStartTime?.dateBySubtractingTimesize(averageDuration!)
            averageStartWindow?.startDate = averageStartWindow?.startDate.dateBySubtractingTimesize(averageDuration!)
            averageStartWindow?.endDate = averageStartWindow?.endDate.dateBySubtractingTimesize(averageDuration!)
        }
        
        
        //////////////////////////////////////////////////////////////////////////
        ///  Phase 4:
        ///  Create window of interest and update any rules that need it
        //////////////////////////////////////////////////////////////////////////
        
        let windowOfInterest = DTTimePeriod(start: averageStartWindow!.startDate!, end: averageStartWindow!.endDate!.dateByAddingTimesize(averageDuration!))
        
        // If backwards, don't let the endDate of the window of interest be greater than the input date & warn if it is.
        if direction == .backward && (windowOfInterest.endDate! as NSDate).isLaterThan(inputDate) {
            printDebug("! Solver Window of Interest end date was later than the input date.  Not possible when solving backwards")
            windowOfInterest.endDate = inputDate
        }
        
        for rule in rules {
            if rule.options.contains(RoleOptions.RequiresInterestWindow) {
                rule.interestPeriod = windowOfInterest
            }
            
            // Combine Avoid periods
            if rule.avoidPeriods != nil {
                for avoidPeriod in rule.avoidPeriods! {
                    detailedAvoidPeriods.append(avoidPeriod)
                }
            }
        }
        
        //////////////////////////////////////////////////////////////////////////
        ///  Phase 5:
        ///  Flatten & Invert the avoid periods.
        ///  (Create free periods from the gaps inbetween)
        //////////////////////////////////////////////////////////////////////////
        
        let avoidPeriods = DTTimePeriodCollection()
        detailedAvoidPeriods.forEach{ avoidPeriods.add($0.period) }
        avoidPeriods.flatten()
        let freePeriods = avoidPeriods.voidPeriods(windowOfInterest)
        
        let preferedPeriod = DTTimePeriod(start: preferedStartTime!, end: preferedStartTime?.dateByAddingTimesize(averageDuration!))
        
        
        //////////////////////////////////////////////////////////////////////////
        ///  Phase 6:
        ///  The Main Algorithm
        //////////////////////////////////////////////////////////////////////////
        
        printDebug("\n\n--------------------------------------------------")
        printDebug("----- Node: \(node.title)")
        printDebug("--------------------------------------------------")
        printDebug("Window of Interest: \(windowOfInterest.log())")
        printDebug("Prefered Period: \(preferedPeriod.log())")
        printDebug("Start Window: \(averageStartWindow?.log())")
        printDebug("Avoid periods: \(avoidPeriods.debugDescription)")
        
        if freePeriods.periods() == nil {
            printDebug("Failed: There are no Free Periods")
            errors.append(SolverError(errorLevel:.failed, error:.noFreePeriods, object:nil, node:node))
            errors.append(contentsOf: clashingPeriods(preferedPeriod, avoidPeriods:detailedAvoidPeriods, node:node))
            return (false, nil, errors)
        }
        
        // Does the corrent node have an event, with a timePeriod that fits into a free Period?
        // Implementing this means events are in their prefered period. But are still valid. Perhaps a setting?
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
        
        // Lets find the best period
        
        var bestPeriod: DTTimePeriod?
        
        for free in freePeriods.periods()! {
            
            // Lets evaluate this free period
            printDebug("--------- Processing New Free Period  ---------")
            printDebug(free.log())
            printDebug("StartWindow Relation to free period: \(averageStartWindow!.relation(to: free).rawValue)")
            
            // The free period must contain the startTimeWindow
            if averageStartWindow!.relation(to: free) == DTTimePeriodRelation.after ||
                averageStartWindow!.relation(to: free) == DTTimePeriodRelation.before ||
                averageStartWindow!.relation(to: free) == DTTimePeriodRelation.none {
                printDebug("StartWindow is not in the Free period, so skipping")
                continue
            }
            
            // Does our preferred window fit into this free period?
            if preferedPeriod.relation(to: free) == DTTimePeriodRelation.inside ||
                preferedPeriod.relation(to: free) == DTTimePeriodRelation.exactMatch {
                printDebug("SOLVED: PreferedPeriod fits")
                return (true, preferedPeriod, errors)
            }
            
            /// Create a possible period
            ///-----------------------------------------
            
            var possiblePeriod: DTTimePeriod?
            
            // The free period is wider than the min spec.
            // So is it earlier(left) or after(right) of the prefered date?
            
            // 1. After(right) the prefered date?
            
            if  free.startDate.isLaterThanOrEqual(to: preferedPeriod.startDate) {
                possiblePeriod = DTTimePeriod()
                possiblePeriod!.startDate = free.startDate!
                let freeDurSecs = abs(free.startDate.seconds(from: free.endDate))
                
                if freeDurSecs >= preferedPeriod.durationInSeconds()  {
                    possiblePeriod!.endDate = free.startDate.addingSeconds(Int(preferedPeriod.durationInSeconds()))
                } else {
                    possiblePeriod!.endDate = free.endDate!
                    
                    // Is it shorter than min Dur?
                    let possDur = Int(possiblePeriod!.durationInSeconds())
                    let avgMinDur = averageMinDuration!.inSeconds()
                    if  possDur < avgMinDur {
                        printDebug("Poss period cancelled because Dur: \(possDur)  avgMinDur:\(avgMinDur)")
                        errors.append(SolverError(errorLevel:.info, error:.nearlyFits, object:[possiblePeriod!], node:node))
                        possiblePeriod = nil
                    }
                }
            }
            
            // 2. Or Before?
            
            if possiblePeriod == nil && free.startDate.isEarlierThan(preferedPeriod.startDate) {
                possiblePeriod = DTTimePeriod()
                
                // lets back date it
                possiblePeriod!.endDate = free.endDate!
                
                let freeDurSecs = abs(free.startDate.seconds(from: free.endDate))
                if freeDurSecs >= preferedPeriod.durationInSeconds()  {
                    possiblePeriod!.startDate = free.endDate.subtractingSeconds(Int(preferedPeriod.durationInSeconds()))
                    
                } else {
                    possiblePeriod!.startDate = free.startDate!
                    let posDur = Int(possiblePeriod!.durationInSeconds())
                    let avgMinDur = averageMinDuration!.inSeconds()
                    if  posDur < avgMinDur {
                        printDebug("Poss period cancelled because Dur: \(posDur)  avgMinDur:\(avgMinDur)")
                        errors.append(SolverError(errorLevel:.info, error:.nearlyFits, object:possiblePeriod!, node:node))
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
            let possDistToStart =  abs(possiblePeriod!.startDate.seconds(from: preferedPeriod.startDate))
            let bestDistToStart = abs(bestPeriod!.startDate.seconds(from: preferedPeriod.startDate))
            if possDistToStart < bestDistToStart { bestPeriod = possiblePeriod }
        }
        
        if bestPeriod != nil {
            printDebug("Found Best Period: \(bestPeriod?.log())")
            return (true, bestPeriod, errors) }
        else {
            printDebug("Failed to solve");
            
            // work out whats clashing with it
            errors.append(contentsOf: clashingPeriods(preferedPeriod, avoidPeriods:detailedAvoidPeriods, node:node))
            return (false,nil, errors) }
    }
    
    
    class func clashingPeriods(_ preferedPeriod:DTTimePeriod, avoidPeriods:[AvoidPeriod], node:Node?) -> [SolverError] {
        var errors = [SolverError]()
        
        for period in avoidPeriods {
            if preferedPeriod.relation(to: period.period) != .none {
                if period.type != .node {
                    errors.append(SolverError(errorLevel: .warning, error:.clash, object:period, node:node))
                }
            }
        }
        return errors
    }
    
    class func InferredPeriodForNode(_ node:Node, inputDate:Date) -> DTTimePeriod? {
        
        switch node.type {
            
        case NodeType.Action:
            var averageDuration: Timesize?
            for rule in node.rules {
                if let dur = rule.eventDuration {
                    if averageDuration != nil {
                        if dur.inSeconds() < averageDuration!.inSeconds() {averageDuration = dur }
                    } else { averageDuration = dur }
                }
            }
            if averageDuration != nil {
                return DTTimePeriod(size: .second, amount: averageDuration!.inSeconds(), startingAt: inputDate)
            } else {
                print("Cannot Calculate Duration")
                return nil
            }
            
            
        case NodeType.Transition:
            var period:DTTimePeriod?
            for rule in node.rules {
                rule.inputDate = inputDate
                if let preferedDate = rule.eventPreferedStartDate {
                    let newPeriod = DTTimePeriod(start: inputDate, end: preferedDate as Date!)
                    if period  == nil { period = newPeriod ; break }
                    if period?.durationInSeconds() > newPeriod?.durationInSeconds() {period = newPeriod}
                }
            }
            if period != nil {
                return period
            } else {
                print("Cannot Calculate Duration")
                return nil
            }
        default: return nil
        }
    }
}

