//
//  NodePresenter.swift
//  Actions
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
    var node: Node
    
    //MARK: Init
    
    override init() {
        self.node = Node()
        super.init()
    }
    
    init(node:Node) {
        self.node = node
        super.init()
    }
    
    public init(pasteboardItem: NSPasteboardItem) {
        if let data = pasteboardItem.dataForType(AppConfiguration.UTI.node) {
            self.node = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Node
        } else {
            fatalError("PasteboardItem didn't contain Node")
        }
        super.init()
    }
    
    
    //MARK: Properties

    public var title: String {
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
    
    public var location: String {
        get {
            return node.location
        }
        set {
            node.location = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
        }
    }
    
    public var notes: String {
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
        set {
            node.type = type
        }
    }
    
    public var rules:[Rule] {
        get {
            return node.rules
        }
    }
    
     var event: CalendarEvent? {
        get {
            return node.event
        }
    }
    
    public var isCompleted: Bool {
        get {
            return node.isCompleted
        }
        set {
            if node.isCompleted != isCompleted {
                node.isCompleted = isCompleted
                sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
            }
        }
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
    
    func removeCalandarEvent(updateState updateState:Bool) {
        node.event?.owner = nil
        node.deleteEvent()
        sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
        if updateState == true { updateNodeState() }
    }
    
    func updateForCalendarExternalChange() {
        guard node.event != nil else { return }
        node.event!.forceNodeToMatchSystemCalendarEvent()
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
        sequencePresenter?.currentState.update(true, presenter: sequencePresenter!) //FIXME: Shouldn't be doing this
    }
    

    
    func deleteRulePresenter(deletedRulePresenter: RulePresenter) {
        node.rules.removeObject(deletedRulePresenter.rule)
        sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
        delegates.forEach { $0.nodePresenterDidChangeRules(self) }
        sequencePresenter?.currentState.update(true, presenter: sequencePresenter!) //FIXME: Shouldn't be doing this
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
        
        
    //MARK: String Generation
    
    public var statusDescription : String? {
        
        func generateErrorString(errors:[SolverError]) -> String? {
            var output=""
            for error in errors {
                if let string = error.errorDescription {
                    output.appendContentsOf(string + ". ")
                }
            }
            return output
        }
        
        func generateStringFromEvent(event:CalendarEvent?) -> String? {
            if event == nil { return "NODE_EVENT_STRING_NO_EVENT".localized }
            var string = event!.startDate.formattedDateWithFormat("dd MMMM HH:mm")
            string.appendContentsOf(" to ")
            string.appendContentsOf(event!.endDate.formattedDateWithFormat("HH:mm"))
            return string
        }
        
        func generateDurationStringFromEvent(event:CalendarEvent?) -> String? {
            guard event != nil else { return nil }
            let form = NSDateComponentsFormatter()
            form.maximumUnitCount = 2
            form.unitsStyle = .Full
            form.allowedUnits = [.Year, .Month, .Day, .Hour, .Minute]
            return form.stringFromDate(event!.startDate, toDate: event!.endDate)
        }
        
        func generateStringFromNodeRules() -> String? {
            let inputDate = NSDate(string: "2015-01-01 10:00", formatString: "YYYY-MM-DD HH:mm")
            if let output = Solver.InferredPeriodForNode(node, inputDate:inputDate) {
                let calculatedEvent = CalendarEvent()
                calculatedEvent.startDate = output.StartDate
                calculatedEvent.endDate = output.EndDate
                return generateDurationStringFromEvent(calculatedEvent)
            } else {
                return "NODE_EVENT_NO_RULES_TO_SET_DURATION".localized
            }
        }
        
        switch currentState {
        case .Ready, .Running, .Completed:
            switch self.type {
                
            case NodeType.Action:
                return generateStringFromEvent(self.event)
                
            case NodeType.Transition:
                if self.event != nil {
                    return generateDurationStringFromEvent(self.event!)
                } else {
                    // calc from the action nodes either side
                    var startDate: NSDate?
                    var endDate: NSDate?
                    if let seq = sequencePresenter {
                        if let indexOfTrans = seq.sequence.nodeChain().indexOf(self.node) {
                            startDate = seq.sequence.nodeChain()[indexOfTrans-1].event?.startDate
                            endDate = seq.sequence.nodeChain()[indexOfTrans+1].event?.endDate
                        }
                    }
                    
                    if startDate != nil && endDate != nil {
                        let calculatedEvent = CalendarEvent()
                        calculatedEvent.startDate = startDate!
                        calculatedEvent.endDate = endDate!
                        return generateDurationStringFromEvent(calculatedEvent)
                    } else {
                        return generateStringFromNodeRules()
                    }
                }
            default: return "ERROR:Invaid Type"
            }
            
        case .Inactive:
            return generateStringFromNodeRules()
            
        case .Error:
            if self.errors != nil { return generateErrorString(self.errors!) } else {
                return "SOLVER_ERROR_UNKNOWN".localized
            }
            
        case .InheritedError:
            return "SOLVER_ERROR_FOLLOWS_FAILED_NODE".localized
            
        default:
            return nil
        }
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
