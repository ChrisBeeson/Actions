//
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2016 Andris Ltd. All rights reserved.
//

import Foundation

public typealias nodeAtIndex = (DiffStep<Node>, Int)

public class SequencePresenter : NSObject {
    
    // MARK: Properties
    
    private var sequence: Sequence?
    public var undoManager: NSUndoManager?
    private var delegates = [SequencePresenterDelegate]()
    
    // MARK: Delegate management
    
    public func addDelegate(delegate:SequencePresenterDelegate) {
        
        if !delegates.contains({$0 === delegate}) {
            delegates.append(delegate)
        }
    }
    
    public func removeDelegate(delegate:SequencePresenterDelegate) {
        
        //delegates = delegates.filter { return $0 !== delegate }
        //delegates.removeObject(delegate)
    }
    
    
    public var title: String {
        get {
            return sequence!.title
        }
        set {
            sequence!.title = newValue
        }
    }
    
    public var archiveableSeq: Sequence {
        return sequence!
    }
    
    
    public var nodes:[Node]? {
        //  precondition(sequence!.validSequence(), "Trying to present a sequence that is not Valid")
        return sequence!.nodeChain()
    }
    
    
    public func renameTitle(newTitle:String) {
        
        undoManager?.prepareWithInvocationTarget(self).renameTitle(title)
        let undoActionName = NSLocalizedString("Rename", comment: "")
        undoManager?.setActionName(undoActionName)
        
        title = newTitle
    }
    
    public func setSequence(sequence: Sequence) {
        self.sequence = sequence
        
        delegates.forEach{ $0.sequencePresenterDidRefreshCompleteLayout(self) }
    }
    
    
    // MARK: Methods
    
    /*
       If node and Int is nil then insertNode will create a new untitled node, and place it at the end of the list.
    */
    
    public func insertActionNode(var node: Node?, index: Int?) {
        
        delegates.forEach { $0.sequencePresenterWillChangeNodeLayout(self) }
        
        if node == nil {
            node = Node(text: AppConfiguration.defaultActionNodeName, type: .Action, rules: nil)
        }
        
        let oldNodes = sequence!.nodeChain()
        sequence!.insertActionNode(node!, index: index)
        informDelegatesOfChangesToNodeChain(oldNodes)
        
        //TODO:Undo
        // undoManager?.prepareWithInvocationTarget(self).removeNode(node)
        let undoActionName = NSLocalizedString("Remove Node", comment: "")
        undoManager?.setActionName(undoActionName)
        
        delegates.forEach { $0.sequencePresenterDidFinishChangingNodeLayout(self) }
    }
    
    
    func informDelegatesOfChangesToNodeChain(oldNodes:[Node]) {
        
        let diff = oldNodes.diff(sequence!.nodeChain())
        
        if (diff.results.count > 0) {
            
            let insertedNodes = diff.insertions.map { ($0, $0.idx) }
            let deletedNodes = diff.deletions.map { ($0, $0.idx) }
            
            delegates.forEach { $0.sequencePresenterDidUpdateChainContents(insertedNodes, deletedNodes:deletedNodes) }
        }
    }
    
    
    public func deleteNodes(nodes: [Node]) {
        
        if nodes.isEmpty { return }
        
        let oldNodes = sequence!.nodeChain()
        nodes.forEach { sequence!.removeActionNode($0) }
        informDelegatesOfChangesToNodeChain(oldNodes)
        
        //TODO: Undo
        /*
        undoManager?.prepareWithInvocationTarget(self).insertNodesForUndo(Array(nodes.reverse()), atIndexes: Array(removedIndexes.reverse()))
        
        let undoActionName = NSLocalizedString("Remove", comment: "")
        undoManager?.setActionName(undoActionName)
        */
    }
    
    
    
    
    
    
    
    /*
    
    @objc public func updateNode(node: Node, withText newText: String) {
    
    precondition((presentedNodes?.contains(node))!, "A list item can only be updated if it already exists in the list.")
    
    // If the text is the same, it's a no op.
    if node.text == newText { return }
    
    let index = presentedNodes!.indexOf(node)!
    
    let oldText = node.text
    
    delegate?.sequencePresenterWillChangeNodeLayout(self, isInitialLayout: false)
    
    node.text = newText
    
    delegate?.sequencePresenter(self, didUpdateNode: node, atIndex: index)
    
    delegate?.sequencePresenterDidChangeNodeLayout(self, isInitialLayout: false)
    
    // Undo
    undoManager?.prepareWithInvocationTarget(self).updateNode(node, withText: oldText)
    
    let undoActionName = NSLocalizedString("Text Change", comment: "")
    undoManager?.setActionName(undoActionName)
    }
    
    
    
    
    @objc public func moveNode(node: Node, toIndex: Int) {
    
    // precondition(canMoveNode(node, toIndex: toIndex), "An item can only be moved if it passes a \"can move\" test.")
    
    delegate?.sequencePresenterWillChangeNodeLayout(self, isInitialLayout: false)
    
    let fromIndex = unsafeMoveNode(node, toIndex: toIndex)
    
    delegate?.sequencePresenterDidChangeNodeLayout(self, isInitialLayout: false)
    
    // Undo
    undoManager?.prepareWithInvocationTarget(self).moveNode(node, toIndex: fromIndex)
    
    let undoActionName = NSLocalizedString("Move", comment: "")
    undoManager?.setActionName(undoActionName)
    }
    
    
    
    */
    
    /**
    Returns the list items at each index in `indexes` within the `presentedNodes` array.
    
    - parameter indexes: The indexes that correspond to the list items that should be retrieved from `presentedNodes`.
    
    - returns:  The list items that are located at each index in `indexes` within `presentedNodes`.
    */
    
    /*
    public func nodesAtIndexes(indexes: NSIndexSet) -> [Node] {
    
    var nodes = [Node]()
    
    nodes.reserveCapacity(indexes.count)
    
    for idx in indexes {
    nodes += [self.presentedNodes?[idx]]
    }
    
    return nodes
    }
    
    */
    
    // MARK: Undo Helper Methods
    
    
    
    /**
    Inserts `nodes` at `indexes`. This is useful for undoing a call to `removeNode(_:)` or
    `removeNodes(_:)` where the opposite action, such as re-inserting the list item, has to be done
    where each list item moves back to its original location before the removal.
    
    - parameter nodes: The list items to insert.
    - parameter indexes: The indexes at which to insert `nodes` into.
    */
    
    /*
    @objc private func insertNodesForUndo(nodes: [Node], atIndexes indexes: [Int]) {
    
    precondition(nodes.count == indexes.count, "`nodes` must have as many elements as `indexes`.")
    
    delegate?.sequencePresenterWillChangeNodeLayout(self, isInitialLayout: false)
    
    for (nodeIndex, node) in nodes.enumerate() {
    let insertionIndex = indexes[nodeIndex]
    
    sequence!.actionNodes.insert(node, atIndex: insertionIndex)
    
    delegate?.sequencePresenter(self, didInsertNode: node, atIndex: insertionIndex)
    }
    
    delegate?.sequencePresenterDidChangeNodeLayout(self, isInitialLayout: false)
    
    // Undo
    
    undoManager?.prepareWithInvocationTarget(self).removeNodes(nodes)
    
    let undoActionName = NSLocalizedString("Remove", comment: "")
    undoManager?.setActionName(undoActionName)
    }
    
    
    
    
    // MARK: Internal Unsafe Updating Methods
    
    
    private func unsafeInsertNode(node: Node, index:Int? = nil) {
    
    precondition((presentedNodes?.contains(node))!, "A list item was requested to be added that is already in the list.")
    
    let indexToInsertNode = index ?? sequence!.actionNodes.count
    
    sequence!.actionNodes.insert(node, atIndex:indexToInsertNode)
    delegate?.sequencePresenter(self, didInsertNode: node, atIndex:indexToInsertNode)
    
    }
    
    
    private func unsafeMoveNode(node: Node, toIndex: Int) -> Int {
    
    precondition((presentedNodes?.contains(node))!, "A list item can only be moved if it already exists in the presented list items.")
    
    let fromIndex = presentedNodes!.indexOf(node)!
    
    sequence!.actionNodes.removeAtIndex(fromIndex)
    sequence!.actionNodes.insert(node, atIndex: toIndex)
    
    delegate?.sequencePresenter(self, didMoveNode: node, fromIndex: fromIndex, toIndex: toIndex)
    
    return fromIndex
    }
    
    */
    
}




