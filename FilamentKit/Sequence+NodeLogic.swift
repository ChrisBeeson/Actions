//
//  Sequence+NodeLogic.swift
//  Filament
//
//  Created by Chris Beeson on 27/10/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation

extension Sequence {
    
    public func nodeChain() -> [Node] {
        
        var nodesToReturn = [Node]()
        
        for node in actionNodes {
            nodesToReturn.append(node)
            if node.rightTransitionNode != nil { nodesToReturn.append(node.rightTransitionNode!) }
        }

        return nodesToReturn
    }
    
    
    public func validSequence() -> Bool {
        
        //    Action -> Transition -> Action -> Transition -> Action
        //    Transitions can only sit inbetween Action nodes
        
        if actionNodes.count == 0 {return false}
        if actionNodes[0].leftTransitionNode != nil {return false}
        if actionNodes.count == 1 { return actionNodes[1].rightTransitionNode == nil ? true : false }
        if actionNodes[actionNodes.count-1].rightTransitionNode != nil { return false }
        
        for var index = 0 ; index < actionNodes.count-1 ; ++index {
            if actionNodes[index].rightTransitionNode != actionNodes[index+1].leftTransitionNode { return false }
        }
        
        let nodes = nodeChain()
        
        for var index = 0 ; index < nodes.count-1 ; ++index {
            if index.isEven() && nodes[index].type != .Action { return false }
        }
        
        return true
    }
    
    
    public func insertActionNode(node: Node, index:Int? = nil) {
        
        precondition(node.type == .Action, "Trying to insert node into sequence that is not of type .Action")
        
        let indexToInsertNode = index ?? self.actionNodes.count
        
        actionNodes.insert(node, atIndex:indexToInsertNode)
        
        node.leftTransitionNode = nil
        node.rightTransitionNode = nil
        
        if actionNodes.count == 1 { return }
        
        if indexToInsertNode > 0 { addTransistionNodeToActionNodes(actionNodes[indexToInsertNode-1], right:node) }
        if indexToInsertNode < actionNodes.count-1 { addTransistionNodeToActionNodes(node, right:actionNodes[indexToInsertNode+1]) }
    }
    
    public func removeActionNode(node:Node) {
        
        let index = actionNodes.indexOf(node)
        
        precondition(index != nil, "Cannot remove Node because it doesn't exist in the sequence.")
        
        actionNodes.removeObject(node)
        
        // it was the only node
        
        if actionNodes.count == 0 { return }
        
        //it was the first one in the array - so remove transistion to the left of it
        
        if index! == 0 {
            transitionNodes.removeObject(actionNodes[0].leftTransitionNode!)
            actionNodes[0].leftTransitionNode = nil
            return
        }
        
        // it was the last
        
        if index! == actionNodes.count - 2 {
            transitionNodes.removeObject(actionNodes[0].rightTransitionNode!)
            return
        }
        
        // it's in the middle of two others
        
        addTransistionNodeToActionNodes(actionNodes[index!-1], right: actionNodes[index!])
    }
    
    
    public func logchain() {
        
        for node in nodeChain() { print (String(node.type) + ": " + node.title) }
        validSequence() ? NSLog("Sequence is Valid") : NSLog("Sequence is NOT Valid")
    }
    
    func forceCreateTransistionNodesForActionNodes() {
        
        if actionNodes.count == 0 {return}
        
        if actionNodes.count == 1 {
            actionNodes[0].leftTransitionNode = nil
            actionNodes[0].rightTransitionNode = nil
            return;
        }
        
        for var index = 0 ; index < actionNodes.count-1 ; ++index {
            
            if actionNodes[index].rightTransitionNode === nil {
                
                addTransistionNodeToActionNodes(actionNodes[index], right:actionNodes[index+1])
            }
        }
    }
    
    
    private func addTransistionNodeToActionNodes(left: Node, right: Node) {
        
        // we need to delete transition node from array if we break any transitions
        // Could return the deleted ones if we need to be notified about that...
        
        if left.rightTransitionNode != nil { transitionNodes.removeObject(left.rightTransitionNode!) }
        if right.leftTransitionNode != nil { transitionNodes.removeObject(right.leftTransitionNode!) }
        
        let name = left.title + " -> " + right.title
        let transitionNode = Node(text: name, type: .Transition, rules: nil)
        
        left.rightTransitionNode = transitionNode
        right.leftTransitionNode = transitionNode
        
        transitionNodes.append(transitionNode)
    }
    
    
    
    
    // This isn't right or complete - what array does this use?
    
    public enum NodePostion: Int { case StartingAction, Transition, Action, EndingAction,None }
    
    public func postion(node: Node) -> NodePostion {
        
        print("using this useless func")
        
        if let index = actionNodes.indexOf(node) {
        
        var result: NodePostion
        
        switch Int(index) {
            
        case 0: result = .StartingAction
        case let x where x == actionNodes.count-1: result = .EndingAction
        case let x where x.isEven(): result = .Action
        default: result = .Action // .Tansaction
        }
        
        return result
            
        } else {
            
            return .None
        }
    }
    
}
