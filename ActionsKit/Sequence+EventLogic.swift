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
    
    func SolveSequence(solvedNode:(node:Node, state:NodeState , errors:[SolverError]?) -> Void) -> Bool {
        guard var time = date else { print("Solver Sequence - no start date set"); return false }
        
        /// Internal Functions
        
        func SolvedActionNode(node:Node, state:NodeState , errors:[SolverError]?) {
            switch calculateActionNodePosition(node) {
                
            case .Action, .StartingAction, .EndingAction:
                if timeDirection == .Forward {
                    if let transitionNode = node.rightTransitionNode {
                        if state == .Error { solvedNode(node: transitionNode, state:.InheritedError, errors: nil) } else {
                            solvedNode(node: transitionNode, state:state, errors: nil)
                        }
                    }
                    solvedNode(node: node, state:state, errors: errors)
                    
                } else if timeDirection == .Backward {
                    
                    if let transitionNode = node.leftTransitionNode {
                        if state == .Error { solvedNode(node: transitionNode, state:.InheritedError, errors: nil) } else {
                            solvedNode(node: transitionNode, state:state, errors: nil)
                        }
                    }
                    solvedNode(node: node, state:state, errors: errors)
                }
            default: print("Found an invaild node")
            }
        }
        
        // Lets begin
        
        var solvedPeriodsToAvoid = [AvoidPeriod]()
        let orderedNodes:[Node] = self.timeDirection == .Forward ? self.actionNodes : self.actionNodes.reverse()
        var failedNode:Node?
        var waitingForUserNode:Node?

        for (index, node) in orderedNodes.enumerate() {
            
            var errors = [SolverError]()
            
            // Skip if node is completed
            if node.isCompleted == true {
                time = (timeDirection == .Forward) ? node.event!.period!.EndDate : node.event!.period!.StartDate
                SolvedActionNode(node, state:.Completed, errors: nil)
                continue
            }
            
            // If we have a failed Node - then lets fail all others
            if failedNode != nil {
                errors.append(SolverError(errorLevel: .Failed, error: .FollowsFailedNode, object: failedNode, node: node))
                SolvedActionNode(node, state:.InheritedError, errors: errors)
                continue
            }
            
            // Handle WaitForUser - works in exactly the same way as failedNodes...

            if waitingForUserNode != nil {
                errors.append(SolverError(errorLevel: .Warning, error: .FollowsRequiresUserInput, object: waitingForUserNode, node: node))
                SolvedActionNode(node, state:.InheritedWait, errors: errors)
                continue
            }
            
            /// Start main processing
            ///------------------------------
            
            var solvedPeriod: SolvedPeriod?
            var rules = node.rules
            
            // add general sequence Rules
            rules.appendContentsOf(self.generalRules)
            
            // add generic app wide rules, if the sequence hasn't overruled them
            let genericRules = AppConfiguration.sharedConfiguration.contextPresenter().rules.filter { !self.generalRules.contains($0) }
            rules.appendContentsOf(genericRules)
            
            // Add rules unique to the calculateActionNodePosition of the node
            switch calculateActionNodePosition(node) {
                
            case .StartingAction:
                let startRule = TransitionDurationWithVariance()
                startRule.eventStartsInDuration = Timesize(unit: .Hour, amount: 0)     /// TODO: This can't be user modified
                rules.append(startRule)
                
            case .Action, .EndingAction:   // add the left hand transistion rules to the rules.
                let transitionRules = (timeDirection == .Forward) ?  node.leftTransitionNode?.rules :  node.rightTransitionNode?.rules
                if transitionRules != nil {
                    for rule in transitionRules! {
                        rules.append(rule) }
                }
                
            default: break
            }
            
            // Remove any calendar events that are created by this sequence, so it doesn't avoid it's self.
            // This is so past updates are ignored
            rules.forEach { if $0.isKindOfClass(AvoidCalendarEventsRule) == true {
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
            errors.appendContentsOf(solvedPeriod!.errors)
            
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
                            errors.append(SolverError(errorLevel: .Warning, error: .RequiresUserInput, object: node, node: node))
                            SolvedActionNode(node, state:.WaitingForUserInput, errors: errors)
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
                    SolvedActionNode(node, state:.Error, errors: errors)
                    continue
                }
            }
            
            // Success
            node.setEventPeriod(solvedPeriod!.period!)
            SolvedActionNode(node, state:.Ready, errors: errors)
            
            solvedPeriodsToAvoid.append(AvoidPeriod(period:solvedPeriod!.period!, type:.Node, object:node))
            
            time = (timeDirection == .Forward) ? solvedPeriod!.period!.EndDate : solvedPeriod!.period!.StartDate
        }
        
        processEventsForTransitionPeriods()
        
        return failedNode == nil ? true : false
    }
    
    
    func  processEventsForTransitionPeriods() {
        
        let allNodes = nodeChain()
        
        for node in transitionNodes {
            
            // Bit of house keeping... This this really the best place for it?
            
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