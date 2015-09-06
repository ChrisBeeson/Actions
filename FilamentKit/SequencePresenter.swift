/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The implementation for the `AllNodesPresenter` type. This class is responsible for managing how a list is presented in the iOS and OS X apps.
*/

import Foundation


final public class SequencePresenter: NSObject, SequencePresenterType {
    
    // MARK: Properties
    
    private var sequence: Sequence?
    private var isInitialSequence = true
    public var undoManager: NSUndoManager?
    
    
    // MARK: SequencePresenterType

    public weak var delegate: SequencePresenterDelegate?

    public var name: String {
        
        get {
            return sequence!.name
        }

        set {
            sequence!.name = newValue
        }
    }
    
    public var archiveableSequence: Sequence {
        
        // The list is already in archiveable form since we're updating it directly.
        return sequence!
    }
    
    public var presentedNodes:[Node] {
        
        // TODO:  Need to return Action and transistion Nodes for UI
        // Should be something like: 
        
        // return sequence.allNodes
        
        // + create private function to validate first.
        
        return sequence!.actionNodes
    }
    

    public func setSequence(sequence: Sequence) {

            self.sequence = sequence
            delegate?.sequencePresenterDidRefreshCompleteLayout(self)
    }

    
    // MARK: Methods


    public func insertNode(node: Node, index: Int?) {
        
        delegate?.sequencePresenterWillChangeNodeLayout(self, isInitialLayout:false)
        
        unsafeInsertNode(node,index: index)
        
        delegate?.sequencePresenterDidChangeNodeLayout(self, isInitialLayout:false)
        
        // Undo
        undoManager?.prepareWithInvocationTarget(self).removeNode(node)
        
        let undoActionName = NSLocalizedString("Remove Node", comment: "")
        undoManager?.setActionName(undoActionName)
    }
    
    public func insertNodes(nodes:[Node]) {
        
        if nodes.isEmpty { return }
        
        delegate?.sequencePresenterWillChangeNodeLayout(self, isInitialLayout: false)
        
        for node in nodes{
            unsafeInsertNode(node)
        }
        
        delegate?.sequencePresenterDidChangeNodeLayout(self, isInitialLayout: false)
        
        // Undo
        undoManager?.prepareWithInvocationTarget(self).removeNodes(nodes)

        let undoActionName = NSLocalizedString("Remove", comment: "")
        undoManager?.setActionName(undoActionName)
    }
    

    @objc public func removeNode(node: Node) {
        
        let nodeIndex = presentedNodes.indexOf(node)
        
        if nodeIndex == nil {
            preconditionFailure("A list item was requested to be removed that isn't in the list.")
        }
        
        delegate?.sequencePresenterWillChangeNodeLayout(self, isInitialLayout: false)
        
        sequence!.actionNodes.removeAtIndex(nodeIndex!)
        
        delegate?.sequencePresenter(self, didRemoveNode: node, atIndex: nodeIndex!)

        delegate?.sequencePresenterDidChangeNodeLayout(self, isInitialLayout: false)

        // Undo
        undoManager?.prepareWithInvocationTarget(self).insertNodesForUndo([node], atIndexes: [nodeIndex!])
        
        let undoActionName = NSLocalizedString("Remove", comment: "")
        undoManager?.setActionName(undoActionName)
    }


    
    @objc public func removeNodes(nodes: [Node]) {
        
        if nodes.isEmpty { return }
        
        delegate?.sequencePresenterWillChangeNodeLayout(self, isInitialLayout: false)
        
        var removedIndexes = [Int]()
        
        for node in nodes {
            if let nodeIndex = presentedNodes.indexOf(node) {
                
                sequence!.actionNodes.removeAtIndex(nodeIndex)
                
                delegate?.sequencePresenter(self, didRemoveNode: node, atIndex: nodeIndex)
                
                removedIndexes += [nodeIndex]
            }
            else {
                preconditionFailure("A list item was requested to be removed that isn't in the list.")
            }
        }
        
        delegate?.sequencePresenterDidChangeNodeLayout(self, isInitialLayout: false)
        
        // Undo
        undoManager?.prepareWithInvocationTarget(self).insertNodesForUndo(Array(nodes.reverse()), atIndexes: Array(removedIndexes.reverse()))
        
        let undoActionName = NSLocalizedString("Remove", comment: "")
        undoManager?.setActionName(undoActionName)
    }
    

    
    @objc public func updateNode(node: Node, withText newText: String) {
        
        precondition(presentedNodes.contains(node), "A list item can only be updated if it already exists in the list.")
        
        // If the text is the same, it's a no op.
        if node.text == newText { return }
        
        let index = presentedNodes.indexOf(node)!
        
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
    



    
    /**
        Returns the list items at each index in `indexes` within the `presentedNodes` array.
    
        - parameter indexes: The indexes that correspond to the list items that should be retrieved from `presentedNodes`.
    
        - returns:  The list items that are located at each index in `indexes` within `presentedNodes`.
    */
    
    public func nodesAtIndexes(indexes: NSIndexSet) -> [Node] {
        
        var nodes = [Node]()
        
        nodes.reserveCapacity(indexes.count)
        
        for idx in indexes {
            nodes += [self.presentedNodes[idx]]
        }
        
        return nodes
    }
    
    // MARK: Undo Helper Methods


    
    /**
        Inserts `nodes` at `indexes`. This is useful for undoing a call to `removeNode(_:)` or
        `removeNodes(_:)` where the opposite action, such as re-inserting the list item, has to be done
        where each list item moves back to its original location before the removal.
    
        - parameter nodes: The list items to insert.
        - parameter indexes: The indexes at which to insert `nodes` into.
    */
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
        
        precondition(!presentedNodes.contains(node), "A list item was requested to be added that is already in the list.")
        
        if let indexToInsertNode = index {
            sequence!.actionNodes.insert(node, atIndex:indexToInsertNode)
            delegate?.sequencePresenter(self, didInsertNode: node, atIndex:indexToInsertNode)
        } else {
            
            sequence!.actionNodes.insert(node, atIndex:sequence!.actionNodes.count)
            delegate?.sequencePresenter(self, didInsertNode: node, atIndex:sequence!.actionNodes.count)
        }
    }
    

    private func unsafeMoveNode(node: Node, toIndex: Int) -> Int {
        
        precondition(presentedNodes.contains(node), "A list item can only be moved if it already exists in the presented list items.")
        
        let fromIndex = presentedNodes.indexOf(node)!

        sequence!.actionNodes.removeAtIndex(fromIndex)
        sequence!.actionNodes.insert(node, atIndex: toIndex)
        
        delegate?.sequencePresenter(self, didMoveNode: node, fromIndex: fromIndex, toIndex: toIndex)
        
        return fromIndex
    }


}
