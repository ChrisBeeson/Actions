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



public class NodePresenter : NSObject, RuleAvailabiltiy {
   
    var undoManager: NSUndoManager?
    var sequencePresenter: SequencePresenter?
    var delegates = [NodePresenterDelegate]()
    private var _currentStatus = NodeStatus.Inactive
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
    
    
    
    var currentStatus: NodeStatus {
        
        get {
            //   _currentStatus.update(self)
            return _currentStatus
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
    
    var isCompleted: Bool {
        get {
            return node.isCompleted
        }
        set {
            node.isCompleted = isCompleted
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
            default: return "Invaid Type"
                
            }
        }
    }
    
    //MARK: Methods
    
    
    func renameTitle(title:String) {
        node.title = title
        node.event?.synchronizeCalendarEvent()
        delegates.forEach { $0.nodePresenterDidChangeTitle(self) }
    }
    
    
    func updateNodeStatus() {
        
        _currentStatus.update(self)
    }
    

    func removeCalandarEvent(updateStatus:Bool) {
        node.deleteEvent()
        if updateStatus == true { updateNodeStatus() }
    }
    
    
    
    //MARK: Rules
    
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
