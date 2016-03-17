//
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools
import Async

public class SequencePresenter : NSObject, RuleAvailabiltiy {
    
    // MARK: Properties
    
    private var _sequence: Sequence?
    var delegates = [SequencePresenterDelegate]()
    var nodePresenters = [NodePresenter]()
    private var _currentState = SequenceState.Void
    public var undoManager: NSUndoManager?
    public var representingDocument: FilamentDocument? {
        didSet {
            undoManager = representingDocument?.undoManager
        }
    }
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserverForName("UpdateAllSequences", object: nil, queue: nil) { (notification) -> Void in
            self.updateState()
        }
    }
    
    public var title: String {
        get {
            return _sequence!.title
        }
        set {
            _sequence!.title = newValue
            representingDocument?.updateChangeCount(.ChangeDone)
        }
    }
    
    var sequence: Sequence {
       assert (_sequence != nil, "Sequence is NULL, and should never be")
        return _sequence!
    }
    
    var nodes:[Node]? {
        return _sequence!.nodeChain()
    }
    
    /// RuleAvailablity
    
    public var type: NodeType { get { return [.Generic] } }
    
    public var rules:[Rule] {
        get {
            return _sequence!.generalRules
        }
    }
    
    /// Date handling
    
    public var date : NSDate? {
        return _sequence!.date
    }
    
    public var completionDate : NSDate? {
        
        if nodes == nil { return nil}
        if nodes!.count == 0 { return nodes![nodes!.count].event?.endDate }
        if let event = nodes![nodes!.count-1].event {
            return event.endDate
        } else {
            return nil
        }
    }
    
    // State
    
    public var currentState: SequenceState {
        return _currentState
    }
    
    
    // MARK: Methods
    

    func setSequence(sequence: Sequence) {
        guard sequence != self._sequence else { return }
        
        self._sequence = sequence
        updateState()
        delegates.forEach{ $0.sequencePresenterDidRefreshCompleteLayout(self) }
    }
    
    
    public func renameTitle(newTitle:String) {
        
        undoManager?.prepareWithInvocationTarget(self).renameTitle(title)
        let undoActionName = NSLocalizedString("Rename", comment: "")
        undoManager?.setActionName(undoActionName)
        
        title = newTitle
    }
    
    public func setDate(date:NSDate?, isStartDate:Bool) {
        
        if date != nil && _sequence!.date != nil && date!.isEqualToDate(_sequence!.date!) && isStartDate == _sequence?.startsAtDate { return }
        
        self.undoManager?.prepareWithInvocationTarget(self).setDate(self.date, isStartDate: true)
        let undoActionName = NSLocalizedString("Change Date", comment: "")
        self.undoManager?.setActionName(undoActionName)
        
        self._sequence!.date = date
        self._sequence!.startsAtDate = isStartDate
        representingDocument?.updateChangeCount(.ChangeDone)
        
        _currentState.toNewStartDate(self)
    }
    

    /*
        If node and Int is nil then insertNode will create a new untitled node, and place it at the end of the list.
    */
    
    func insertActionNode(var node: Node?, index: Int?) {
        
        delegates.forEach { $0.sequencePresenterWillChangeNodeLayout(self) }
        
        if node == nil {
            node = Node(text: AppConfiguration.defaultActionNodeName, type: .Action, rules: nil)
        }
        
        let oldNodes = _sequence!.nodeChain()
        _sequence!.insertActionNode(node!, index: index)
         representingDocument?.updateChangeCount(.ChangeDone)
        
        informDelegatesOfChangesToNodeChain(oldNodes)
        
        undoManager?.prepareWithInvocationTarget(self).deleteNodes([node!])
        let undoActionName = NSLocalizedString("Insert Node", comment: "")
        undoManager?.setActionName(undoActionName)
        
        delegates.forEach { $0.sequencePresenterDidFinishChangingNodeLayout(self) }
        
        updateState()
    }
    
    
    func deleteNodes(nodes: [Node]) {
        
        if nodes.isEmpty { return }
        
        let oldNodes = _sequence!.nodeChain()
        
        for node in nodes {
            nodePresenters = nodePresenters.filter {$0.node != node}
            _sequence!.removeActionNode(node)
        }
        
        representingDocument?.updateChangeCount(.ChangeDone)
        
        informDelegatesOfChangesToNodeChain(oldNodes)
        /*
        for node in nodes.reverse() {
        undoManager?.prepareWithInvocationTarget(self).insertActionNode(node, index: nil)
        let undoActionName = NSLocalizedString("Delete Node", comment: "")
        undoManager?.setActionName(undoActionName)
        }
        */
        
        updateState()
    }
    
    // MARK: Presenter

    func presenterForNode(node:Node) -> NodePresenter {
        
        let presenter = nodePresenters.filter {$0.node === node}
        if presenter.count == 1 { return presenter[0] }
        
        let newPresenter = NodePresenter(node: node)
        newPresenter.undoManager = representingDocument?.undoManager
        newPresenter.sequencePresenter = self
        nodePresenters.append(newPresenter)
        return newPresenter
    }
    
    
    
    func informDelegatesOfChangesToNodeChain(oldNodes:[Node]) {
        
        let diff = oldNodes.diff(_sequence!.nodeChain())
        
        if (diff.results.count > 0) {
            
            let insertedNodes = Set(diff.insertions.map { NSIndexPath (forItem: $0.idx , inSection: 0)})
            let deletedNodes = Set(diff.deletions.map {NSIndexPath (forItem: $0.idx , inSection: 0)})
            
            delegates.forEach { $0.sequencePresenterDidUpdateChainContents(insertedNodes, deletedNodes:deletedNodes) }
        }
        updateState()
    }
    
    
    // MARK: State
    
    public func updateState() {
        guard _sequence != nil else { return }
        _currentState.update(self)
    }
    
    public func prepareForCompleteDeletion() {
        if _currentState != .Completed {
            for presenter in nodePresenters {
                presenter.removeCalandarEvent(false)
            }
        }
        representingDocument?.updateChangeCount(.ChangeDone)
    }
    
    
    //MARK: Rules
    
    
    public func addRulePresenter(rule:RulePresenter, atIndex:Int) {
        
        guard atIndex > -1 && atIndex <= sequence.generalRules.count else { return }
        sequence.generalRules.insert(rule.rule, atIndex: atIndex)
        delegates.forEach{ $0.sequencePresenterDidChangeGeneralRules(self) }
        representingDocument?.updateChangeCount(.ChangeDone)
    }
    
    public func removeRulePresenter(rule:RulePresenter) {
        
        sequence.generalRules.removeObject(rule.rule)
        delegates.forEach{ $0.sequencePresenterDidChangeGeneralRules(self) }
        representingDocument?.updateChangeCount(.ChangeDone)
    }
   
    
    //MARK: Pasteboard
    
    public func pasteboardItem() -> NSPasteboardItem {
        
        let seqCopy = self.sequence.copy() as! Sequence
        seqCopy.date = nil
        seqCopy.startsAtDate = true
        seqCopy.nodeChain().forEach { $0.event = nil ; $0.isCompleted = false }
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(seqCopy)
        let item = NSPasteboardItem()
        item.setData(data, forType: AppConfiguration.UTI.sequence)
        return item
    }
    
    
    
//MARK: Delegate helpers
    
    public func addDelegate(delegate:SequencePresenterDelegate) {
        if !delegates.contains({$0 === delegate}) {
            delegates.append(delegate)
        }
    }
    
    public func removeDelegate(delegate:SequencePresenterDelegate) {
        
        delegates = delegates.filter { return $0 !== delegate }
    }
}