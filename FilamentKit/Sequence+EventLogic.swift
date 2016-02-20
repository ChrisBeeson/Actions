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
            
            // Add Rules
            
            var rules = node.rules
            
            // Avoid filament calendar
            
            rules.append(AvoidCalendarEvents(calendars: [CalendarManager.sharedInstance.applicationCalendar!]))
            
            // TODO: app generic rules

            
            switch postion(node) {
                
            case .StartingAction:
                
                let startRule = EventStartsInTimeFromNow()
                startRule.eventStartsInDuration = TimeSize(unit: .Hour, amount: 0)
                rules.append(startRule)
                
                solvedPeriod = Solver.calculateEventPeriod(time, rules:rules)
                
                
            case .Action, .EndingAction:   // add the left hand transistion rules to the rules.
                
                if let transistionRules = node.leftTransitionNode?.rules {
                    for rule in transistionRules {
                        rules.append(rule) }
                }
                
                solvedPeriod = Solver.calculateEventPeriod(time, rules:rules)
                
            default: break
                
            }
            
            if solvedPeriod == nil || solvedPeriod!.solved == false {
                
                //TODO: delete all events this node onwards
                
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
            
            if node.leftTransitionNode == nil {
                if  let index = allNodes.indexOf(node) where index != -1 {
                    node.leftTransitionNode = allNodes[index-1]
                }
            }
            
            if node.rightTransitionNode == nil {
                if  let index = allNodes.indexOf(node) where index != -1 {
                    node.rightTransitionNode = allNodes[index+1]
                }
            }
            
            let start = node.leftTransitionNode?.event!.endDate.dateByAddingSeconds(1)
            let end = node.rightTransitionNode?.event!.startDate.dateBySubtractingSeconds(1)
            
            if start != nil && end != nil {
                let period = DTTimePeriod(startDate: start, endDate: end)
                node.setEventPeriod(period)
            } else {
                print("Start and End Dates when processEventsForTransitionPeriods")
            }
        }
    }
    
}