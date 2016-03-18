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
    
    func UpdateEvents() -> (success:Bool, firstFailedNode:Node?) {
        
        guard var time = date else { return (false,nil) }
        
        for node in self.actionNodes {
            
            var solvedPeriod: SolvedPeriod?
            var rules = node.rules
            
            // add general sequence Rules
            rules.appendContentsOf(self.generalRules)
            
            // add generic app wide rules, if the sequence hasn't overruled them
            // if an event for this event already exists we need to remove it so it doesn't clash with its self.
            
            let genericRules = AppConfiguration.sharedConfiguration.contextPresenter().rules.filter { !self.generalRules.contains($0) }
            rules.appendContentsOf(genericRules)
            
            switch postion(node) {
                
            case .StartingAction:
                
                let startRule = TransitionDurationWithVariance()
                startRule.eventStartsInDuration = TimeSize(unit: .Hour, amount: 0)     /// TODO: This can't be user modified
                rules.append(startRule)
                
                solvedPeriod = Solver.calculateEventPeriod(time, node: node, rules:rules)
                
                
            case .Action, .EndingAction:   // add the left hand transistion rules to the rules.
                
                if let transistionRules = node.leftTransitionNode?.rules {
                    for rule in transistionRules {
                        rules.append(rule) }
                }
                
                rules.forEach { if $0.isKindOfClass(AvoidCalendarEventsRule) == true {
                    ($0 as! AvoidCalendarEventsRule).ignoreCurrentEventsForSequence = self  // Is there a better way to do this?
                    }
                }
                
                solvedPeriod = Solver.calculateEventPeriod(time, node: node, rules:rules)
                
            default: break
                
            }
            
            if solvedPeriod == nil || solvedPeriod!.solved == false {
                processEventsForTransitionPeriods()
                return (false, node)
            }
            
            time = solvedPeriod!.period!.EndDate
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