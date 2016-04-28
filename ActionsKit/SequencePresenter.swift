//
//  Actions
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools
import Async

public class SequencePresenter : NSObject, RuleAvailabiltiy {
    
    public var currentState = SequenceState.Void
    public var undoManager: NSUndoManager?
    weak public var representingDocument: ActionsDocument?
    var delegates = [SequencePresenterDelegate]()
    private var _nodePresenters = [NodePresenter]()
    private weak var _sequence: Sequence?
    private var _shouldBeDeleted = false

    var nodePresenters : [NodePresenter] {
        return _sequence!.nodeChain().map { nodePresenter($0) }
    }
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserverForName("UpdateAllSequences", object: nil, queue: nil) { (notification) -> Void in
            if self.representingDocument != nil {
                if self._shouldBeDeleted == false {
                    self.updateState(processEvents:true)
                } else {
                    print("Trying to update a sequence that should be DELETED!!")
                }
            }
        }
    }
    
    deinit { print("SequencePresenter deinit") }
    
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
    
    /// Rule Availablity
    
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
    
    public var timeDirection: TimeDirection {
        return _sequence!.timeDirection
    }
    
    // CompletionDate is set during sequence State update
    public var completionDate : NSDate?
    
    // MARK: Methods
    
    func setSequence(sequence: Sequence) {
        guard sequence != self._sequence else { return }
        self._sequence = sequence
        updateState(processEvents:false)
        delegates.forEach{ $0.sequencePresenterDidRefreshCompleteLayout(self) }
    }
    
    
    public func renameTitle(newTitle:String) {
        undoManager?.prepareWithInvocationTarget(self).renameTitle(title)
        let undoActionName = "UNDO_RENAME_ACTION".localized
        undoManager?.setActionName(undoActionName)
        
        title = newTitle
        representingDocument?.updateChangeCount(.ChangeDone)
    }
    

    public func setDate(date:NSDate?, direction:TimeDirection) {
        if date != nil && _sequence!.date != nil && date!.isEqualToDate(_sequence!.date!) && direction == _sequence?.timeDirection { return }
        
        self.undoManager?.prepareWithInvocationTarget(self).setDate(self.date, direction: self.timeDirection)
        let undoActionName = "UNDO_CHANGE_DATE".localized
        self.undoManager?.setActionName(undoActionName)
        
        let timeDirectionToggled = direction == _sequence?.timeDirection ? false : true
        self._sequence!.date = date
        self._sequence!.timeDirection = direction
        representingDocument?.updateChangeCount(.ChangeDone)
        
        currentState.toNewStartDate(self)
        if timeDirectionToggled ==  true {
            delegates.forEach{ $0.sequencePresenterDidRefreshCompleteLayout(self) }
        }
    }
    
    
    func insertActionNode(node: Node?, actionNodesIndex: Int?, informDelegates:Bool) {
        //If node and Int is nil then insertNode will create a new untitled node, and place it at the end of the list.
        var nodeToinsert: Node
        var indx = actionNodesIndex
        
        if node == nil {
            nodeToinsert = Node(text: AppConfiguration.defaultActionNodeName, type: .Action, rules: nil)
        } else {
            nodeToinsert = node!
        }
        
        // If running backwards insert at index 0
        if indx == nil && timeDirection == .Backward { indx = 0 }
        
        let oldNodes = _sequence!.nodeChain()
        _sequence!.insertActionNode(nodeToinsert, index:indx)
        representingDocument?.updateChangeCount(.ChangeDone)
        
        if informDelegates == true { informDelegatesOfChangesToNodeChain(oldNodes) }
        
        undoManager?.registerUndoWithTarget(self, handler: { (self) -> () in
            self.deleteNodes([nodeToinsert], informDelegates: informDelegates)
            })
        undoManager?.setActionName("UNDO_INSERT_ACTION".localized)
    }
    
    
    func deleteNodes(nodes: [Node], informDelegates:Bool) {
        if nodes.isEmpty { return }
        let oldNodes = _sequence!.nodeChain()
        
        for node in nodes {
            node.event?.deleteCalenderEvent()
            _sequence!.removeActionNode(node)
            
            let indx = sequence.actionNodes.indexOf(node)
            undoManager?.registerUndoWithTarget(self, handler: { [oldNode = node, oldIndx = indx] (self) -> () in
                self.insertActionNode(oldNode, actionNodesIndex: oldIndx, informDelegates:informDelegates)
                })
            undoManager?.setActionName("UNDO_DELETE_ACTION".localized)
        }
        
        representingDocument?.updateChangeCount(.ChangeDone)
        if informDelegates == true { informDelegatesOfChangesToNodeChain(oldNodes) }
    }
    
    func moveNode(fromActionNodesIndex:Int, toActionNodesIndex:Int) {
        assert(fromActionNodesIndex < sequence.actionNodes.count)
        //  let oldNodes = _sequence!.nodeChain()
        let node = sequence.actionNodes[fromActionNodesIndex]
        deleteNodes([node], informDelegates: false)
        let insertIdx = toActionNodesIndex <= fromActionNodesIndex ? toActionNodesIndex : (toActionNodesIndex - 1)
        insertActionNode(node, actionNodesIndex:insertIdx, informDelegates: false)
         delegates.forEach{ $0.sequencePresenterDidRefreshCompleteLayout(self) }
        //   informDelegatesOfChangesToNodeChain(oldNodes)
    }
    
    // MARK: Node Presenter
    
    func nodePresenter(node:Node) -> NodePresenter {
        let presenter = _nodePresenters.filter {$0.node === node}
        if presenter.count == 1 {
            return presenter[0]
        }
        
        let newPresenter = NodePresenter(node: node)
        newPresenter.undoManager = representingDocument?.undoManager
        newPresenter.sequencePresenter = self
        _nodePresenters.append(newPresenter)
        return newPresenter
    }
    
    
    func informDelegatesOfChangesToNodeChain(oldNodes:[Node]) {
        let diff = oldNodes.diff(_sequence!.nodeChain())
        if (diff.results.count > 0) {
            let insertedNodes = Set(diff.insertions.map { NSIndexPath (forItem: $0.idx , inSection: 0)})
            let deletedNodes = Set(diff.deletions.map {NSIndexPath (forItem: $0.idx , inSection: 0)})
            delegates.forEach { $0.sequencePresenterDidUpdateChainContents(insertedNodes, deletedNodes:deletedNodes) }
        }
        updateState(processEvents:true)
    }
    
    // MARK: State
    
    public func updateState(processEvents processEvents: Bool) {
        guard _sequence != nil else { return }
        currentState.update(processEvents, presenter: self)
    }
    
    public func prepareForCompleteDeletion() {
        self._shouldBeDeleted = true
        if currentState != .Completed {
            for presenter in _nodePresenters {
                presenter.removeCalandarEvent(updateState: false)
            }
        }
    }
    
    //MARK: Rule Presenters
    
    public func addRulePresenter(rule:RulePresenter, atIndex:Int) {
        guard atIndex > -1 && atIndex <= sequence.generalRules.count else { return }
        // guard rule.rule.type.contains[""] else { return }
        sequence.generalRules.insert(rule.rule, atIndex: atIndex)
        delegates.forEach{ $0.sequencePresenterDidChangeGeneralRules(self) }
        updateState(processEvents:true)
        representingDocument?.updateChangeCount(.ChangeDone)
    }
    
    public func removeRulePresenter(rule:RulePresenter) {
        sequence.generalRules.removeObject(rule.rule)
        delegates.forEach{ $0.sequencePresenterDidChangeGeneralRules(self) }
        updateState(processEvents:true)
        representingDocument?.updateChangeCount(.ChangeDone)
    }
    
    //MARK: Pasteboard
    
    public func pasteboardItem() -> NSPasteboardItem {
        let seqCopy = self.representingDocument!.container!.copy() as! Container
        seqCopy.sequences[0].date = nil
        seqCopy.sequences[0].timeDirection = .Forward
        seqCopy.sequences[0].nodeChain().forEach { $0.event = nil ; $0.isCompleted = false }
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(seqCopy)
        let item = NSPasteboardItem()
        item.setData(data, forType: AppConfiguration.UTI.container)
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
