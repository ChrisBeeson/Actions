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
    
    
    var event: Event? {
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
                _currentStatus = calcNodeStatus()
            }
        }
    }
    
    
    //MARK: Methods

    
    func renameTitle(title:String) {
        node.title = title
        node.event?.updateCalendarData()
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
        
        if newStatus != _currentStatus {
            delegates.forEach { $0.nodePresenterDidChangeStatus(self, toStatus:newStatus) }
            print("Node \(node.title) : \(newStatus)")
        }
        
        _currentStatus = newStatus
        
    }
    
    
    func calcNodeStatus() -> NodeStatus {

        // if the node has an error it cannot be removed here - not sure why but it's a rule I've made up
        if _currentStatus == .Error { return .Error }
    
        var newStatus = NodeStatus.Void
        
        if node.event == nil { return .inActive }
        if node.event!.startDate.isLaterThan(NSDate())  { newStatus = .Ready }
        if node.event!.startDate.isEarlierThanOrEqualTo(NSDate()) && node.event!.endDate.isLaterThanOrEqualTo(NSDate())  {
            newStatus = .Running
        }
        if node.event!.endDate.isEarlierThanOrEqualTo(NSDate()) { newStatus = .Completed }
        
        assert(newStatus != .Void, "updateNodeStatus came up with Void")
        return newStatus
    }
    
    
    func insertRules(rules:[Rule]) {
        
        node.rules.appendContentsOf(rules)
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
