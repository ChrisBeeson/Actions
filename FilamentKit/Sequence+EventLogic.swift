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
            
            processEventWithPeriod(solvedPeriod!.period!, node:node)
        }
        
        return (true,nil)
    }
    
    
    private func processEventWithPeriod(period:DTTimePeriod, node:Node) {
        
        // Does this node already have a correct event?
        
        if node.event != nil && node.event!.startDate.isEqualToDate(period.StartDate) == true && node.event?.endDate.isEqualToDate(period.EndDate) == true {
            return
        }
        
        let store = CalendarManager.sharedInstance.store
        
        // Node has an Event, but it's wrong so lets delete it.
        
        if node.event != nil {
            
            do {
                
                try store.removeEvent(node.event!, span: .ThisEvent, commit: true)
                
            } catch let error as NSError {
                
                print("Unresolved error deleting Event \(error), \(error.userInfo)")
            }
            
            node.event = nil
            
        }
        
        //TODO: rather than delete out of Date events, move them.
        
        
        // Create Event
        
        let event = EKEvent(eventStore: store)
        event.title = node.title
        event.startDate = period.StartDate
        event.endDate = period.EndDate
        
        if let appCal = CalendarManager.sharedInstance.applicationCalendar {
            
            event.calendar = appCal
            
        } else {
            
            print("No Application Calendar")
        }
        
        // Publish it
        
        do {
            
            try store.saveEvent(event, span: .ThisEvent, commit: true)
            
        } catch let error as NSError {
            
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
    }
}