//
//  Sequence+EventLogic.swift
//  Filament
//
//  Created by Chris Beeson on 27/10/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools
import EventKit


extension Sequence {
    
    //TODO: updateEvents(startingNode:Node)
    
    func UpdateEvents() -> (success:Bool, firstFailedNode:Node?) {
        
        guard var time = date else { return (false,nil) }
        
        var solvedPeriodsToAvoid = [DTTimePeriod]()
        
        for node in self.actionNodes {
            
            var solvedPeriod: SolvedPeriod?
            var rules = node.rules
            
            // add general sequence Rules
            rules.appendContentsOf(self.generalRules)
            
            // add generic app wide rules, if the sequence hasn't overruled them
            let genericRules = AppConfiguration.sharedConfiguration.contextPresenter().rules.filter { !self.generalRules.contains($0) }
            rules.appendContentsOf(genericRules)
            
            // Add rules unique to the postion of the node
            switch postion(node) {
                
            case .StartingAction:
                
                let startRule = TransitionDurationWithVariance()
                startRule.eventStartsInDuration = TimeSize(unit: .Hour, amount: 0)     /// TODO: This can't be user modified
                rules.append(startRule)

            case .Action, .EndingAction:   // add the left hand transistion rules to the rules.
                
                if let transistionRules = node.leftTransitionNode?.rules {
                    for rule in transistionRules {
                        rules.append(rule) }
                }
        
            default: break
            }
            
            // Remove any calendar events that are created by this sequence, so it doesn't avoid it's self.
            rules.forEach { if $0.isKindOfClass(AvoidCalendarEventsRule) == true {
                ($0 as! AvoidCalendarEventsRule).ignoreCurrentEventsForSequence = self
                //  ($0 as! AvoidCalendarEventsRule).ignoreCurrentEventForNode = node
                }
            }
            
            // add a rule that returns avoid periods of the periods that have been solved
            let avoidSolvedPeriodsRule = Rule()
            avoidSolvedPeriodsRule.avoidPeriods = solvedPeriodsToAvoid
            rules.append(avoidSolvedPeriodsRule)
            
            // Solve it!
            solvedPeriod = Solver.calculateEventPeriod(time, node: node, rules:rules)
            
            // we failed
            if solvedPeriod == nil || solvedPeriod!.solved == false {
                processEventsForTransitionPeriods()
                return (false, node)
            }
            
            // We did it!
            time = solvedPeriod!.period!.EndDate
            solvedPeriodsToAvoid.append(solvedPeriod!.period!)
            node.setEventPeriod(solvedPeriod!.period!)
        }
        
        processEventsForTransitionPeriods()
        return (true,nil)
    }
    
    
    func  processEventsForTransitionPeriods() {
        
        let allNodes = nodeChain()
        
        for node in transitionNodes {
            
            // Bit of house keeping... really shouldn't go here.
            
            if  let index = allNodes.indexOf(node) where index != -1 {
                node.leftTransitionNode = allNodes[index-1]
            }
            
            if  let index = allNodes.indexOf(node) where index != -1 {
                node.rightTransitionNode = allNodes[index+1]
            }
            
            let start = node.leftTransitionNode?.event?.endDate.dateByAddingSeconds(1)
            let end = node.rightTransitionNode?.event?.startDate.dateBySubtractingSeconds(1)
            
            if start != nil && end != nil {
                let period = DTTimePeriod(startDate: start, endDate: end)
                node.setEventPeriod(period)
            } else {
                //Node failed
                node.deleteEvent()
            }
        }
        
        //  nodeChain().forEach { print("\($0.type):  \($0.event!.startDate.formattedDateWithFormat("hh:mm"))  ->  \($0.event!.endDate.formattedDateWithFormat("hh:mm"))")}
    }
}