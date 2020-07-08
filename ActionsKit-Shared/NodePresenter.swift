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

open class NodePresenter : NSObject, RuleAvailabiltiy {
    
    var undoManager: UndoManager?
    weak var sequencePresenter: SequencePresenter?
    var delegates = [NodePresenterDelegate]()
    var currentState = NodeState.inactive
    fileprivate var rulePresenters = [RulePresenter]()
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
        if let data = pasteboardItem.data(forType: AppConfiguration.UTI.node) {
            self.node = NSKeyedUnarchiver.unarchiveObject(with: data) as! Node
        } else {
            fatalError("PasteboardItem didn't contain Node")
        }
        super.init()
    }
    
    
    //MARK: Properties

    open var title: String {
        get {
            return node.title
        }
        set {
            (undoManager?.prepare(withInvocationTarget: self) as AnyObject).renameTitle(node.title)
            let undoActionName = NSLocalizedString("Rename", comment: "")
            undoManager?.setActionName(undoActionName)
            
            renameTitle(newValue)
        }
    }
    
    open var location: String {
        get {
            return node.location
        }
        set {
            node.location = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
        }
    }
    
    open var notes: String {
        get {
            // if node.notes.isEmpty { return nil }
            return node.notes
        }
        set {
            node.notes = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
        }
    }
    
    open var type: NodeType {
        get {
            return node.type
        }
        set {
            node.type = type
        }
    }
    
    open var rules:[Rule] {
        get {
            return node.rules
        }
    }
    
     var event: CalendarEvent? {
        get {
            return node.event
        }
    }
    
    open var isCompleted: Bool {
        get {
            return node.isCompleted
        }
        set {
            if node.isCompleted != isCompleted {
                node.isCompleted = isCompleted
                sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
            }
        }
    }
    

    //MARK: Methods

    func renameTitle(_ title:String) {
        node.title = title
        sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
        node.event?.synchronizeCalendarEvent()
        delegates.forEach { $0.nodePresenterDidChangeTitle(self) }
    }
    
    func updateNodeState() {
        currentState.update(self)
    }
    
    func removeCalandarEvent(updateState:Bool) {
        node.event?.owner = nil
        node.deleteEvent()
        sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
        if updateState == true { updateNodeState() }
    }
    
    func updateForCalendarExternalChange() {
        guard node.event != nil else { return }
        node.event!.forceNodeToMatchSystemCalendarEvent()
    }
    
    
    //MARK: Rules
    
    func insertRulePresenter(_ rulePresenter:RulePresenter, atIndex:Int) {
        // -1 means if it's new, put it at the end of the list, if it's not new, overwrite the current... (or update it at least)
        
        if atIndex != -1 {
            node.rules.insert(rulePresenter.rule, at: atIndex)
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
        sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
        delegates.forEach { $0.nodePresenterDidChangeRules(self) }
        sequencePresenter?.currentState.update(true, presenter: sequencePresenter!) //FIXME: Shouldn't be doing this
    }
    

    
    func deleteRulePresenter(_ deletedRulePresenter: RulePresenter) {
        node.rules.removeObject(deletedRulePresenter.rule)
        sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
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
        let data = NSKeyedArchiver.archivedData(withRootObject: self.node)
        let item = NSPasteboardItem()
        item.setData(data, forType: AppConfiguration.UTI.node)
        return item
    }
        
        
    //MARK: String Generation
    
    open var statusDescription : String? {
        
        func generateErrorString(_ errors:[SolverError]) -> String? {
            var output=""
            for error in errors {
                if let string = error.errorDescription {
                    output.append(string + ". ")
                }
            }
            return output
        }
        
        func generateStringFromEvent(_ event:CalendarEvent?) -> String? {
            if event == nil { return "NODE_EVENT_STRING_NO_EVENT".localized }
            var string = (event!.startDate as NSDate).formattedDate(withFormat: "dd MMMM HH:mm")
            string.append(" to ")
            string.append((event!.endDate as NSDate).formattedDate(withFormat: "HH:mm"))
            return string
        }
        
        func generateDurationStringFromEvent(_ event:CalendarEvent?) -> String? {
            guard event != nil else { return nil }
            let form = DateComponentsFormatter()
            form.maximumUnitCount = 2
            form.unitsStyle = .full
            form.allowedUnits = [.year, .month, .day, .hour, .minute]
            return form.string(from: event!.startDate as Date, to: event!.endDate as Date)
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
        case .ready, .running, .completed:
            switch self.type {
                
            case NodeType.Action:
                return generateStringFromEvent(self.event)
                
            case NodeType.Transition:
                if self.event != nil {
                    return generateDurationStringFromEvent(self.event!)
                } else {
                    // calc from the action nodes either side
                    var startDate: Date?
                    var endDate: Date?
                    if let seq = sequencePresenter {
                        if let indexOfTrans = seq.sequence.nodeChain().index(of: self.node) {
                            startDate = seq.sequence.nodeChain()[indexOfTrans-1].event?.startDate as Date?
                            endDate = seq.sequence.nodeChain()[indexOfTrans+1].event?.endDate as Date?
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
            
        case .inactive:
            return generateStringFromNodeRules()
            
        case .error:
            if self.errors != nil { return generateErrorString(self.errors!) } else {
                return "SOLVER_ERROR_UNKNOWN".localized
            }
            
        case .inheritedError:
            return "SOLVER_ERROR_FOLLOWS_FAILED_NODE".localized
            
        default:
            return nil
        }
    }
    
    // MARK: Delegate management
    
    func addDelegate(_ delegate:NodePresenterDelegate) {
        if !delegates.contains(where: {$0 === delegate}) {
            delegates.append(delegate)
        }
    }
    
    func removeDelegate(_ delegate:NodePresenterDelegate) {
        delegates = delegates.filter { return $0 !== delegate }
    }
}
