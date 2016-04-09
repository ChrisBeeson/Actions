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
    weak var sequencePresenter: SequencePresenter?
    var delegates = [NodePresenterDelegate]()
    var currentState = NodeState.Inactive
    private var rulePresenters = [RulePresenter]()
    var errors: [SolverError]?
    
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
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
        }
    }
    
    var notes: String {
        get {
            // if node.notes.isEmpty { return nil }
            return node.notes
        }
        set {
            node.notes = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
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
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
        }
    }
    
    
    var humanReadableString : String? {
        switch currentState {
        case .Ready, .Running, .Completed:
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
            
        case .Error:
            guard errors != nil else { return nil }
            var output=""
            for error in errors! {
                if let string = error.humanReadableString {
                output.appendContentsOf(string + ". ")
                }
            }
        default:
            return nil
        }
        return nil
    }

    
    //MARK: Methods

    func renameTitle(title:String) {
        node.title = title
        sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
        node.event?.synchronizeCalendarEvent()
        delegates.forEach { $0.nodePresenterDidChangeTitle(self) }
    }
    
    func updateNodeState() {
        currentState.update(self)
    }
    
    func removeCalandarEvent(updateState:Bool) {
        node.deleteEvent()
        sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
        if updateState == true { updateNodeState() }
    }
    
    
    //MARK: Rules
    
    func insertRulePresenter(rulePresenter:RulePresenter, atIndex:Int) {
        // -1 means if it's new, put it at the end of the list, if it's not new, overwrite the current... (or update it at least)
        
        if atIndex != -1 {
            node.rules.insert(rulePresenter.rule, atIndex: atIndex)
        } else {
            // first do we already have this rule?
            if wouldAcceptRulePresenter(rulePresenter, allowDuplicates: false) == true {
                // this is a new rule
                node.rules.append(rulePresenter.rule)
            } else {
                // replace rule of the same class with this one
                for rule in node.rules {
                    if rule.className == rulePresenter.rule.className {
                        node.rules.removeObject(rule)
                        node.rules.append(rulePresenter.rule)
                        break
                    }
                }
            }
        }
        sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
        delegates.forEach { $0.nodePresenterDidChangeRules(self) }
    }
    
    func insertRules(rules:[Rule]) {
        node.rules.appendContentsOf(rules)
        sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
        delegates.forEach { $0.nodePresenterDidChangeRules(self) }
    }
    
    
    func deleteRulePresenter(deletedRulePresenter: RulePresenter) {
        node.rules.removeObject(deletedRulePresenter.rule)
        sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
        delegates.forEach { $0.nodePresenterDidChangeRules(self) }
    }
    
    
    func prepareForDeletion() {
        rulePresenters.removeAll()
        node.event = nil
        delegates.removeAll()
        sequencePresenter = nil
    }
    
    //MARK: Pasteboard
    
    func pasteboardItem() -> NSPasteboardItem {
        let data = NSKeyedArchiver.archivedDataWithRootObject(self.node)
        let item = NSPasteboardItem()
        item.setData(data, forType: AppConfiguration.UTI.node)
        return item
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
