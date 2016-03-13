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

public class NodePresenter : NSObject, RuleAvailabiltiy {
    
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
    
    override init() {
        self.node = Node()
        super.init()
    }
    
    init(node:Node) {
        self.node = node
        super.init()
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
    
    var location: String {
        get {
            return node.location
        }
        set {
            node.location = newValue
        }
    }
    
    
    var notes: String {
        get {
            // if node.notes.isEmpty { return nil }
            return node.notes
        }
        set {
            node.notes = newValue
        }
    }
    
    public var type: NodeType {
        get {
            return node.type
        }
    }
    
    public var rules:[Rule] {
        get {
            return node.rules
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
    
    
    var event: TimeEvent? {
        get {
            return node.event
        }
    }
    
    var humanReadableEventString : String {
        get {

            switch self.type {
            case NodeType.Action:
                if self.event == nil {
                    return "NODE_EVENT_STRING_NO_EVENT".localized
                }
            
                var string = self.event!.startDate.formattedDateWithFormat("dd MMMM HH:mm")
                string.appendContentsOf(" to ")
                string.appendContentsOf(self.event!.endDate.formattedDateWithFormat("HH:mm"))
                return string
                
            case NodeType.Transition: return "Transition"
                
                // Do we have events
            default: return "Invaid Type"
                
            }
            return "Nil"
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
    
    /*
    func rulePresenterForRule(rule:Rule) -> RulePresenter {
        
        let presenter = rulePresenters.filter {$0.rule === rule}
        if presenter.count == 1 { return presenter[0] }
        
        let newPresenter = RulePresenter.rulePresenterForRule(rule)
        newPresenter.undoManager = self.undoManager
        rulePresenters.append(newPresenter)
        return newPresenter
    }
    
    */
    
    
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
