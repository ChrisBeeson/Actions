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
    
    public func UpdateEvents() -> (success:Bool, firstFailedNode:Node?) {
        
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
            node.updateCalendarEventWithTimePeriod(solvedPeriod!.period!)
        }
        return (true,nil)
    }
}