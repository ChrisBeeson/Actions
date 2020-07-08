//
//  Sequence+EventLogic.swift
//  Actions
//
//  Created by Chris Beeson on 27/10/2015.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools
import EventKit

extension Sequence {
    
    func SolveSequence(_ solvedNode:@escaping (_ node:Node, _ state:NodeState , _ errors:[SolverError]?) -> Void) -> Bool {
        guard var time = date else { print("Solver Sequence - no start date set"); return false }
        
        /// Internal Functions
        
        func SolvedActionNode(_ node:Node, state:NodeState , errors:[SolverError]?) {
            switch calculateActionNodePosition(node) {
                
            case .action, .startingAction, .endingAction:
                if timeDirection == .forward {
                    if let transitionNode = node.rightTransitionNode {
                        if state == .error { solvedNode(transitionNode, .inheritedError, nil) } else {
                            solvedNode(transitionNode, state, nil)
                        }
                    }
                    solvedNode(node, state, errors)
                    
                } else if timeDirection == .backward {
                    
                    if let transitionNode = node.leftTransitionNode {
                        if state == .error { solvedNode(transitionNode, .inheritedError, nil) } else {
                            solvedNode(transitionNode, state, nil)
                        }
                    }
                    solvedNode(node, state, errors)
                }
            default: print("Found an invaild node")
            }
        }
        
        // Lets begin
        
        var solvedPeriodsToAvoid = [AvoidPeriod]()
        let orderedNodes:[Node] = self.timeDirection == .forward ? self.actionNodes : self.actionNodes.reversed()
        var failedNode:Node?
        var waitingForUserNode:Node?

        for (index, node) in orderedNodes.enumerated() {
            
            var errors = [SolverError]()
            
            // Skip if node is completed
            if node.isCompleted == true {
                time = (timeDirection == .forward) ? node.event!.period!.endDate : node.event!.period!.startDate
                SolvedActionNode(node, state:.completed, errors: nil)
                continue
            }
            
            // If we have a failed Node - then lets fail all others
            if failedNode != nil {
                errors.append(SolverError(errorLevel: .failed, error: .followsFailedNode, object: failedNode, node: node))
                SolvedActionNode(node, state:.inheritedError, errors: errors)
                continue
            }
            
            // Handle WaitForUser - works in exactly the same way as failedNodes...

            if waitingForUserNode != nil {
                errors.append(SolverError(errorLevel: .warning, error: .followsRequiresUserInput, object: waitingForUserNode, node: node))
                SolvedActionNode(node, state:.inheritedWait, errors: errors)
                continue
            }
            
            /// Start main processing
            ///------------------------------
            
            var solvedPeriod: SolvedPeriod?
            var rules = node.rules
            
            // add general sequence Rules
            rules.append(contentsOf: self.generalRules)
            
            // add generic app wide rules, if the sequence hasn't overruled them
            let genericRules = AppConfiguration.sharedConfiguration.contextPresenter().rules.filter { !self.generalRules.contains($0) }
            rules.append(contentsOf: genericRules)
            
            // Add rules unique to the calculateActionNodePosition of the node
            switch calculateActionNodePosition(node) {
                
            case .startingAction:
                let startRule = TransitionDurationWithVariance()
                startRule.eventStartsInDuration = Timesize(unit: .Hour, amount: 0)     /// TODO: This can't be user modified
                rules.append(startRule)
                
            case .action, .endingAction:   // add the left hand transistion rules to the rules.
                let transitionRules = (timeDirection == .forward) ?  node.leftTransitionNode?.rules :  node.rightTransitionNode?.rules
                if transitionRules != nil {
                    for rule in transitionRules! {
                        rules.append(rule) }
                }
                
            default: break
            }
            
            // Remove any calendar events that are created by this sequence, so it doesn't avoid it's self.
            // This is so past updates are ignored
            rules.forEach { if $0.isKind(of: AvoidCalendarEventsRule.self) == true {
                ($0 as! AvoidCalendarEventsRule).ignoreCurrentEventsForSequence = self
                //($0 as! AvoidCalendarEventsRule).ignoreCurrentEventForNode = node
                }
            }
            
            // Add Avoid periods that have already been solved in this update
            
            let avoidSolvedPeriodsRule = Rule()
            avoidSolvedPeriodsRule.avoidPeriods = solvedPeriodsToAvoid
            rules.append(avoidSolvedPeriodsRule)
        
            
            // Pre-Solver
            //------------------------

            if index > 0 {
                if let event = orderedNodes[index - 1].event {
                    let period = event.timePeriod()
                    rules.forEach{ $0.previousPeriod = period }
                    node.rules.forEach{ $0.previousPeriod = period }  //FIXME: ???
                }
            }
            
            rules.forEach { rules = $0.preSolverCodeBlock(rules: rules) }
            
            // What if more that one rule whats to mod date?

            // Solver
            //-------------------------------------------------------------------------------------------------------
            
            solvedPeriod = Solver.calculateEventPeriod(time, direction:timeDirection, node: node, rules:rules)
            errors.append(contentsOf: solvedPeriod!.errors)
            
            //-------------------------------------------------------------------------------------------------------
            
            
            // Post-Solver
            //-----------------------
            
            if solvedPeriod?.period != nil { rules.forEach{$0.solvedPeriod = solvedPeriod?.period!} }
            rules.forEach{ $0.postSolverCodeBlock() }
            //TODO: Calendar events get updated here?
            
            
            // Result processing
            //--------------------------
            
            // Waiting For User
            
            if solvedPeriod!.solved == true {
                
                for rule in node.rules {
                    if rule is WaitForUserRule {
                        if (rule as! WaitForUserRule).userContinued == false {
                            errors.append(SolverError(errorLevel: .warning, error: .requiresUserInput, object: node, node: node))
                            SolvedActionNode(node, state:.waitingForUserInput, errors: errors)
                            waitingForUserNode = node
                            break
                        } else {
                            waitingForUserNode = nil
                        }
                    }
                }
                if waitingForUserNode != nil { continue }
            }
            
            
            // Failed
            if solvedPeriod!.solved == false {
                if failedNode == nil {
                    failedNode = node
                    SolvedActionNode(node, state:.error, errors: errors)
                    continue
                }
            }
            
            // Success
            node.setEventPeriod(solvedPeriod!.period!)
            SolvedActionNode(node, state:.ready, errors: errors)
            
            solvedPeriodsToAvoid.append(AvoidPeriod(period:solvedPeriod!.period!, type:.node, object:node))
            
            time = (timeDirection == .forward) ? solvedPeriod!.period!.endDate : solvedPeriod!.period!.startDate
        }
        
        processEventsForTransitionPeriods()
        
        return failedNode == nil ? true : false
    }
    
    
    func  processEventsForTransitionPeriods() {
        
        let allNodes = nodeChain()
        
        for node in transitionNodes {
            
            // Bit of house keeping... This this really the best place for it?
            
            if  let index = allNodes.index(of: node) , index != -1 {
                node.leftTransitionNode = allNodes[index-1]
            }
            
            if  let index = allNodes.index(of: node) , index != -1 {
                node.rightTransitionNode = allNodes[index+1]
            }
            
            let start = ((node.leftTransitionNode?.event?.endDate)! as NSDate).addingSeconds(1)
            let end = ((node.rightTransitionNode?.event?.startDate)! as NSDate).subtractingSeconds(1)
            
            if start != nil && end != nil {
                let period = DTTimePeriod(start: start, end: end)
                node.setEventPeriod(period)
            } else {
                //Node failed
                node.deleteEvent()
            }
        }
        
        //  nodeChain().forEach { print("\($0.type):  \($0.event!.startDate.formattedDateWithFormat("hh:mm"))  ->  \($0.event!.endDate.formattedDateWithFormat("hh:mm"))")}
    }
}
