/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Simple internal helper functions to share across `IncompleteNodesPresenter` and `AllNodesPresenter`. These functions help diff two arrays of `Node` objects.
*/

import Foundation

/// An enum to keep track of the different kinds of changes that may take place within a list.
enum NodesBatchChangeKind {
    case Removed
    case Inserted
    case Toggled
    case UpdatedText
    case Multiple
}

/// Returns an array of `Node` objects in `initialNodes` that don't exist in `changedNodes`.
func findRemovedActionNodes(initialNodes initialNodes: [Node], changedNodes: [Node]) -> [Node] {
    return initialNodes.filter { !changedNodes.contains($0) }
}

/// Returns an array of `Node` objects in `changedNodes` that don't exist in `initialNodes`.
func findInsertedActionNodes(initialNodes initialNodes: [Node], changedNodes: [Node], filter filterHandler: Node -> Bool = { _ in return true }) -> [Node] {
    return changedNodes.filter { !initialNodes.contains($0) && filterHandler($0) }
}



/**
    Returns an array of `Node` objects in `changedNodes` whose text changed from `initialNodes`
    relative to `changedNodes.
*/
func findNodesWithUpdatedText(initialNodes initialNodes: [Node], changedNodes: [Node]) -> [Node] {
    return changedNodes.filter { changedNode in
        if let indexOfChangedNodeInInitialNodes = initialNodes.indexOf(changedNode) {
            let initialNode = initialNodes[indexOfChangedNodeInInitialNodes]

            if initialNode.text != changedNode.text {
                return true
            }
        }
        
        return false
    }
}

/**
    Update `replaceableNewNodes` in place with all of the list items that are equal in `previousUnchangedNodes`.
    For example, if `replaceableNewNodes` has list items of UUID "1", "2", and "3" and `previousUnchangedNodes`
    has list items of UUID "2" and "3", the `replaceableNewNodes` array will have it's list items with UUID
    "2" and "3" replaced with the list items whose UUID is "2" and "3" in `previousUnchangedNodes`. This is
    used to ensure that the list items in multiple arrays are referencing the same objects in memory as what the
    presented list items are presenting.
*/
func replaceAnyEqualUnchangedNewNodesWithPreviousUnchangedNodes(inout replaceableNewNodes replaceableNewNodes: [Node], previousUnchangedNodes: [Node]) {
    let replaceableNewNodesCopy = replaceableNewNodes
    
    for (idx, replaceableNewNode) in replaceableNewNodesCopy.enumerate() {
        if let indexOfUnchangedNode = previousUnchangedNodes.indexOf(replaceableNewNode) {
            replaceableNewNodes[idx] = previousUnchangedNodes[indexOfUnchangedNode]
        }
    }
}

/**
    Returns the type of `NodesBatchChangeKind` based on the different types of changes. The parameters for
    this function should be based on the result of the functions above. If there were no changes whatsoever,
    `nil` is returned.
*/
func nodesBatchChangeKindForChanges(removedNodes removedNodes: [Node], insertedNodes: [Node], toggledNodes: [Node], nodesWithUpdatedText: [Node]) -> NodesBatchChangeKind? {
    /**
        Switch on the different scenarios that we can isolate uniquely for whether or not changes were made in
        a specific kind of change. Look at the case values for a quick way to see which batch change kind is
        being targeted.
    */

    switch (!removedNodes.isEmpty, !insertedNodes.isEmpty, !toggledNodes.isEmpty, !nodesWithUpdatedText.isEmpty) {
        case (false, false, false, false):  return nil
        case (true,  false, false, false):  return .Removed
        case (false, true,  false, false):  return .Inserted
        case (false, false, true,  false):  return .Toggled
        case (false, false, false, true):   return .UpdatedText
        default:                            return .Multiple
    }
}
