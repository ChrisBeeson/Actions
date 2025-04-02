//
//  Actions
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

open class SequencePresenter : NSObject, RuleAvailabiltiy {
    
    open var currentState = SequenceState.void
    open var undoManager: UndoManager?
    weak open var representingDocument: ActionsDocument?
    var delegates = [SequencePresenterDelegate]()
    fileprivate var _nodePresenters = [NodePresenter]()
    fileprivate weak var _sequence: Sequence?
    fileprivate var _shouldBeDeleted = false

    var nodePresenters : [NodePresenter] {
        guard _sequence != nil else { return [NodePresenter]() }
        return _sequence!.nodeChain().map { nodePresenter($0) }
    }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UpdateAllSequences"), object: nil, queue: nil) { (notification) -> Void in
            if self.representingDocument != nil {
                if self._shouldBeDeleted == false {
                    self.updateState(processEvents:true)
                } else {
                    print("Trying to update a sequence that should be DELETED!!")
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "SystemCalendarDidChangeExternally"), object: nil, queue: nil) { (notification) -> Void in
            
            self.nodePresenters.forEach { $0.updateForCalendarExternalChange() }
        }
        
        
    }
    
    deinit { print("SequencePresenter deinit") }
    
    open var title: String {
        get {
            return _sequence!.title
        }
        set {
            _sequence!.title = newValue
            representingDocument?.updateChangeCount(.changeDone)
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
    
    open var type: NodeType { get { return [.Generic] } }
    
    open var rules:[Rule] {
        get {
            return _sequence!.generalRules
        }
    }
    
    /// Date handling
    
    open var date : Date? {
        return _sequence!.date as Date?
    }
    
    open var timeDirection: TimeDirection {
        return _sequence!.timeDirection
    }
    
    // CompletionDate is set during sequence State update
    open var completionDate : Date?
    
    // MARK: Methods
    
    func setSequence(_ sequence: Sequence) {
        guard sequence != self._sequence else { return }
        self._sequence = sequence
        updateState(processEvents:false)
        delegates.forEach{ $0.sequencePresenterDidRefreshCompleteLayout(self) }
    }
    
    
    open func renameTitle(_ newTitle:String) {
        (undoManager?.prepare(withInvocationTarget: self) as AnyObject).renameTitle(title)
        let undoActionName = "UNDO_RENAME_ACTION".localized
        undoManager?.setActionName(undoActionName)
        
        title = newTitle
        representingDocument?.updateChangeCount(.changeDone)
    }
    

    open func setDate(_ date:Date?, direction:TimeDirection) {
        if date != nil && _sequence!.date != nil && (date! == _sequence!.date! as Date) && direction == _sequence?.timeDirection { return }
        
        (self.undoManager?.prepare(withInvocationTarget: self) as AnyObject).setDate(self.date, direction: self.timeDirection)
        let undoActionName = "UNDO_CHANGE_DATE".localized
        self.undoManager?.setActionName(undoActionName)
        
        let timeDirectionToggled = direction == _sequence?.timeDirection ? false : true
        self._sequence!.date = date
        self._sequence!.timeDirection = direction
        representingDocument?.updateChangeCount(.changeDone)
        
        currentState.toNewStartDate(self)
        if timeDirectionToggled ==  true {
            delegates.forEach{ $0.sequencePresenterDidRefreshCompleteLayout(self) }
        }
    }
    
    
    func insertActionNode(_ node: Node?, actionNodesIndex: Int?, informDelegates:Bool) {
        //If node and Int is nil then insertNode will create a new untitled node, and place it at the end of the list.
        var nodeToinsert: Node
        var indx = actionNodesIndex
        
        if node == nil {
            nodeToinsert = Node(text: AppConfiguration.defaultActionNodeName, type: .Action, rules: nil)
        } else {
            nodeToinsert = node!
        }
        
        // If running backwards insert at index 0
        if indx == nil && timeDirection == .backward { indx = 0 }
        
        let oldNodes = _sequence!.nodeChain()
        _sequence!.insertActionNode(nodeToinsert, index:indx)
        representingDocument?.updateChangeCount(.changeDone)
        
        if informDelegates == true { informDelegatesOfChangesToNodeChain(oldNodes) }
        
        undoManager?.registerUndo(withTarget: self, handler: { (self) -> () in
            self.deleteNodes([nodeToinsert], informDelegates: informDelegates)
            })
        undoManager?.setActionName("UNDO_INSERT_ACTION".localized)
    }
    
    
    func deleteNodes(_ nodes: [Node], informDelegates:Bool) {
        if nodes.isEmpty { return }
        let oldNodes = _sequence!.nodeChain()
        
        for node in nodes {
            node.event?.deleteCalenderEvent()
            _sequence!.removeActionNode(node)
            
            let indx = sequence.actionNodes.index(of: node)
            undoManager?.registerUndo(withTarget: self, handler: { [oldNode = node, oldIndx = indx] (self) -> () in
                self.insertActionNode(oldNode, actionNodesIndex: oldIndx, informDelegates:informDelegates)
                })
            undoManager?.setActionName("UNDO_DELETE_ACTION".localized)
        }
        
        representingDocument?.updateChangeCount(.changeDone)
        if informDelegates == true { informDelegatesOfChangesToNodeChain(oldNodes) }
    }
    
    func moveNode(_ fromActionNodesIndex:Int, toActionNodesIndex:Int) {
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
    
    func nodePresenter(_ node:Node) -> NodePresenter {
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
    
    
    func informDelegatesOfChangesToNodeChain(_ oldNodes:[Node]) {
        let diff = oldNodes.diff(_sequence!.nodeChain())
        if (diff.results.count > 0) {
            let insertedNodes = Set(diff.insertions.map { IndexPath (forItem: $0.idx , inSection: 0)})
            let deletedNodes = Set(diff.deletions.map {IndexPath (forItem: $0.idx , inSection: 0)})
            delegates.forEach { $0.sequencePresenterDidUpdateChainContents(insertedNodes, deletedNodes:deletedNodes) }
        }
        updateState(processEvents:true)
    }
    
    // MARK: State
    
    open func updateState(processEvents: Bool) {
        guard _sequence != nil else { return }
        currentState.update(processEvents, presenter: self)
    }
    
    open func prepareForCompleteDeletion() {
        self._shouldBeDeleted = true
        if currentState != .completed {
            for presenter in _nodePresenters {
                presenter.removeCalandarEvent(updateState: false)
            }
        }
    }
    
    //MARK: Rule Presenters
    
    open func addRulePresenter(_ rule:RulePresenter, atIndex:Int) {
        guard atIndex > -1 && atIndex <= sequence.generalRules.count else { return }
        // guard rule.rule.type.contains[""] else { return }
        sequence.generalRules.insert(rule.rule, at: atIndex)
        delegates.forEach{ $0.sequencePresenterDidChangeGeneralRules(self) }
        updateState(processEvents:true)
        representingDocument?.updateChangeCount(.changeDone)
    }
    
    open func removeRulePresenter(_ rule:RulePresenter) {
        sequence.generalRules.removeObject(rule.rule)
        delegates.forEach{ $0.sequencePresenterDidChangeGeneralRules(self) }
        updateState(processEvents:true)
        representingDocument?.updateChangeCount(.changeDone)
    }
    
    //MARK: Pasteboard
    
    open func pasteboardItem() -> NSPasteboardItem {
        let seqCopy = self.representingDocument!.container!.copy() as! Container
        seqCopy.sequences[0].date = nil
        seqCopy.sequences[0].timeDirection = .forward
        seqCopy.sequences[0].nodeChain().forEach { $0.event = nil ; $0.isCompleted = false }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: seqCopy)
        let item = NSPasteboardItem()
        item.setData(data, forType: AppConfiguration.UTI.container)
        return item
    }
    
    //MARK: Delegate helpers
    
    open func addDelegate(_ delegate:SequencePresenterDelegate) {
        if !delegates.contains(where: {$0 === delegate}) {
            delegates.append(delegate)
        }
    }
    
    open func removeDelegate(_ delegate:SequencePresenterDelegate) {
        delegates = delegates.filter { return $0 !== delegate }
    }
}
