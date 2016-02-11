/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Helper functions to perform common operations in `IncompleteNodesPresenter` and `chainPresenter`.
*/

import Foundation

/**
    Removes each list item found in `nodesToRemove` from the `initialNodes` array. For each removal,
    the function notifies the `sequencePresenter`'s delegate of the change.
*/
//func removeNodesFromNodesWithListPresenter(sequencePresenter: SequencePresenterType, inout initialNodes: [Node], nodesToRemove: [Node]) {
//    let sortedNodesToRemove = nodesToRemove.sort { initialNodes.indexOf($0)! > initialNodes.indexOf($1)! }
//    
//    for nodeToRemove in sortedNodesToRemove {
//        // Use the index of the list item to remove in the current list's list items.
//        let indexOfNodeToRemoveInOldList = initialNodes.indexOf(nodeToRemove)!
//        
//        initialNodes.removeAtIndex(indexOfNodeToRemoveInOldList)
//        
//        sequencePresenter.delegate?.sequencePresenter(sequencePresenter, didRemoveNode: nodeToRemove, atIndex: indexOfNodeToRemoveInOldList)
//    }
//}

/**
    Inserts each list item in `nodesToInsert` into `initialNodes`. For each insertion, the function
    notifies the `sequencePresenter`'s delegate of the change.
*/
//func insertNodesIntoNodesWithListPresenter(sequencePresenter: SequencePresenterType, inout initialNodes: [Node], nodesToInsert: [Node]) {
//    for (idx, insertedIncompleteNode) in nodesToInsert.enumerate() {
//        initialNodes.insert(insertedIncompleteNode, atIndex: idx)
//        
//        sequencePresenter.delegate?.sequencePresenter(sequencePresenter, didInsertNode: insertedIncompleteNode, atIndex: idx)
//    }
//}

/**
    Replaces the stale list items in `presentedNodes` with the new ones found in `newUpdatedNodes`. For
    each update, the function notifies the `sequencePresenter`'s delegate of the update.
*/

/*
func updateNodesWithNodesForListPresenter(sequencePresenter: SequencePresenterType, inout presentedNodes: [Node], newUpdatedNodes: [Node]) {
    for newlyUpdatedNode in newUpdatedNodes {
        let indexOfNode = presentedNodes.indexOf(newlyUpdatedNode)!
        
        presentedNodes[indexOfNode] = newlyUpdatedNode
        
        sequencePresenter.delegate?.sequencePresenter(sequencePresenter, didUpdateNode: newlyUpdatedNode, atIndex: indexOfNode)
    }

*/
//}

