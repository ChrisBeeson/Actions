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

enum NodeStatus: Int { case inActive, Ready, Running, WaitingForUserInput, Completed, Error, Void }

class NodePresenter : NSObject {
    
    var undoManager: NSUndoManager?
    private var delegates = [NodePresenterDelegate]()
    private var _currentStatus = NodeStatus.Void
    private var _hasRuleError = false
    
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
            return updateNodeStatus()
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
            node.title = newValue
            delegates.forEach { $0.nodePresenterDidChangeTitle(self) }
            /*
            undoManager?.prepareWithInvocationTarget(self).renameTitle(title)
            let undoActionName = NSLocalizedString("Rename", comment: "")
            undoManager?.setActionName(undoActionName)
            */
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
    
    var sceduledDate :NSDate? {
        get {
            return nil
        }
    }
    
    var rules:[Rule] {
        get {
            return node.rules
        }
    }
    
    var calendarEvent: EKEvent? {
        get {
            return node.event
        }
    }
    
    var hasRuleError:Bool {
        get {
            return _hasRuleError
        }
        set {
            _hasRuleError = newValue
            if _hasRuleError == true { _currentStatus = .Error } else {
                _currentStatus = updateNodeStatus()
            }
        }
    }
    
    
    //MARK: Methods
    
    func updateNodeStatus() -> NodeStatus {
        
        // if the node has an error it cannot be removed here.
        if _currentStatus == .Error { return .Error }
        
        var newStatus = NodeStatus.Void
        
        // if we don't have an event
        if node.event == nil { newStatus = .inActive } else {
            
            // if we have an event but we're before time
            if (node.event?.startDate.isLaterThan(NSDate())) != nil { newStatus = .Ready }
            
            // we're in the middle of this event
            if node.event!.startDate.isEarlierThanOrEqualTo(NSDate()) && node.event!.endDate.isLaterThanOrEqualTo(NSDate())  {
                newStatus = .Running
            }
            
            // event is after
            if node.event!.endDate.isEarlierThanOrEqualTo(NSDate()) { newStatus = .Completed }
        }
        
        assert(newStatus != .Void, "updateNodeStatus came up with Void")
        
        if newStatus != _currentStatus {
            delegates.forEach { $0.nodePresenterDidChangeStatus(self, toStatus:newStatus) }
        }
        
        _currentStatus = newStatus
        
        return _currentStatus
    }
    
    
    func insertRules(rules:[Rule]) {
        
        node.rules.appendContentsOf(rules)
        delegates.forEach { $0.nodePresenterDidChangeRules(self) }
    }
    
    
    func removeRules(rules:[Rule]) {
        
        delegates.forEach { $0.nodePresenterDidChangeRules(self) }
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
