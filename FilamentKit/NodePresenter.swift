//
//  NodePresenter.swift
//  Filament
//
//  Created by Chris Beeson on 13/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import EventKit
import DateTools

enum NodeStatus: Int { case Inactive, Ready, Running, WaitingForUserInput, Completed, Error, Void }

class NodePresenter : NSObject {
    
    var undoManager: NSUndoManager?
    var sequencePresenter: SequencePresenter?
    private var delegates = [NodePresenterDelegate]()
    private var _currentStatus = NodeStatus.Void
    private var _hasRuleError = false
    private var rulePresenters = [RulePresenter]()
    
    //MARK: Properties
    
    var node: Node {
        didSet {
        }
    }
    
    init(node:Node) {
        self.node = node
        super.init()
    }
    
    var type: NodeType {
        get {
            return node.type
        }
    }
    
    var currentStatus:NodeStatus {
        
        get {
            return calcNodeStatus()
        }
        set {
            _currentStatus = newValue
        }
    }
    
    
    var title: String {
        get {
            return node.title
        }
        set {
            undoManager?.prepareWithInvocationTarget(self).renameTitle(node.title)
            let undoActionName = NSLocalizedString("Rename", comment: "")
            undoManager?.setActionName(undoActionName)
            
            renameTitle(newValue)
        }
    }
    
    var notes: String {
        get {
            return node.notes
        }
        set {
            node.notes = newValue
            delegates.forEach { $0.nodePresenterDidChangeNotes(self) }
        }
    }
    
    
    var rules:[Rule] {
        get {
            return node.rules
        }
    }
    
    
    var event: TimeEvent? {
        get {
            return node.event
        }
    }
    
    //MARK: Methods
    
    
    func renameTitle(title:String) {
        node.title = title
        node.event?.synchronizeCalendarEvent()
        delegates.forEach { $0.nodePresenterDidChangeTitle(self) }
    }
    
    
    func updateNodeStatus() {
        
        let newStatus = calcNodeStatus()
        
        switch newStatus {
            
        case .Ready:
            let secsToStart = node.event!.startDate.secondsLaterThan(NSDate())
            NSTimer.schedule(delay: secsToStart+0.1) { timer in
                self.updateNodeStatus()
            }
            
        case .Running:
            let secsToComplete = node.event!.endDate.secondsLaterThan(NSDate())
            NSTimer.schedule(delay: secsToComplete+0.1) { timer in
                self.updateNodeStatus()
            }
            
        default: break
        }
        
        delegates.forEach { $0.nodePresenterDidChangeStatus(self, toStatus:newStatus) }
        //    print("Node \(node.title) : \(newStatus)")
        _currentStatus = newStatus
    }
    
    
    func calcNodeStatus() -> NodeStatus {
        
        // if the node has an error it cannot be removed here - not sure why but it's a rule I've made up
        if _currentStatus == .Error { return .Error }
        
        var newStatus = NodeStatus.Void
        
        if node.event == nil { return .Inactive }
        if node.event!.startDate.isLaterThan(NSDate())  { newStatus = .Ready }
        if node.event!.startDate.isEarlierThanOrEqualTo(NSDate()) && node.event!.endDate.isLaterThanOrEqualTo(NSDate())  {
            newStatus = .Running
        }
        if node.event!.endDate.isEarlierThanOrEqualTo(NSDate()) { newStatus = .Completed }
        
        assert(newStatus != .Void, "updateNodeStatus came up with Void")
        return newStatus
    }
    
    
    //MARK: Rules
    
    func rulePresenterForRule(rule:Rule) -> RulePresenter {
        
        let presenter = rulePresenters.filter {$0.rule === rule}
        if presenter.count == 1 { return presenter[0] }
        
        let newPresenter = RulePresenter.rulePresenterForRule(rule)
        newPresenter.undoManager = self.undoManager
        rulePresenters.append(newPresenter)
        return newPresenter
    }
    
    
    func allRulePresenters() -> [RulePresenter] {
        
        var presenters = [RulePresenter]()
        for rule in node.rules {
           presenters.append(rulePresenterForRule(rule))
        }
        return presenters
    }
    
    
    func availableRules() -> [Rule] {
        
        var avalRules = Rule.RuleClasses()
        
        for aRule in avalRules {
            for rule in rules {
                if aRule.className == rule.className {
                    avalRules = avalRules.filter{ $0.className != rule.className }
                }
            }
            
            if aRule.availableToNodeType != .All && aRule.availableToNodeType != self.type {
                avalRules = avalRules.filter{ $0.className != aRule.className }
            }
        }
        return avalRules
    }
    
    
    
    func insertRulePresenter(rulePresenter:RulePresenter, atIndex:Int) {
        
        node.rules.insert(rulePresenter.rule, atIndex: atIndex)
        delegates.forEach { $0.nodePresenterDidChangeRules(self) }
    }
    
    func insertRules(rules:[Rule]) {
        
        node.rules.appendContentsOf(rules)
        delegates.forEach { $0.nodePresenterDidChangeRules(self) }
    }
    
    
    func deleteRulePresenter(deletedRulePresenter: RulePresenter) {
      
        node.rules.removeObject(deletedRulePresenter.rule)
        delegates.forEach { $0.nodePresenterDidChangeRules(self) }
    }
    
    
    func removeRules(rules:[Rule]) {
        
        // delegates.forEach { $0.nodePresenterDidChangeRules(self) }
    }
    
    
    // MARK: Delegate management
    
    func addDelegate(delegate:NodePresenterDelegate) {
        
        if !delegates.contains({$0 === delegate}) {
            delegates.append(delegate)
        }
    }
    
    func removeDelegate(delegate:NodePresenterDelegate) {
        delegates = delegates.filter { return $0 !== delegate }
    }
}
