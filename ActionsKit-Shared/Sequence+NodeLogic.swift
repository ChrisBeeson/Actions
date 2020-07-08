//
//  Sequence+NodeLogic.swift
//  Actions
//
//  Created by Chris Beeson on 27/10/2015.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

extension Sequence {
	
	func nodeChain() -> [Node] {
		
		var nodesToReturn = [Node]()
		
		for (index, node) in actionNodes.enumerated() {
			nodesToReturn.append(node)
			
			var transitionNode:Node?
			switch timeDirection {
			case .forward: transitionNode = node.rightTransitionNode
			case .backward:
				if index+1 < actionNodes.count {
					transitionNode = actionNodes[index+1].leftTransitionNode
				}
			}
			
			if transitionNode != nil { nodesToReturn.append(transitionNode!) }
			/*
			else {
			if actionNodes.count > 1 {
			let action = timeDirection == .Forward ? NodePostion.EndingAction : NodePostion.StartingAction
			//print ( "Not an Ending Action Node does not have a transition Node")
			//assert (self.calculateActionNodePosition(node) == action, "Not an Ending Action Node does not have a transition Node")
			}
			}
			*/
		}
		return nodesToReturn
	}
	
	
	func validSequence() -> Bool {
		
		//  Action -> Transition -> Action -> Transition -> Action
		//  Transitions can only sit inbetween Action nodes
		
		if actionNodes.count == 0 {return false}
		if actionNodes[0].leftTransitionNode != nil {return false}
		if actionNodes.count == 1 { return actionNodes[1].rightTransitionNode == nil ? true : false }
		if actionNodes[actionNodes.count-1].rightTransitionNode != nil { return false }
		
		for index in 0 ..< actionNodes.count-1  {
			if actionNodes[index].rightTransitionNode != actionNodes[index+1].leftTransitionNode { return false }
		}
		
		let nodes = nodeChain()
		
		for index in 0 ..< nodes.count-1  {
			if index.isEven() && nodes[index].type != .Action { return false }
		}
		return true
	}
	
	
	func insertActionNode(_ node: Node, index:Int? = nil) {
		precondition(node.type == .Action, "Trying to insert node into sequence that is not of type .Action")
		
		var indexToInsertNode = index ?? self.actionNodes.count
		if indexToInsertNode > self.actionNodes.count { indexToInsertNode = self.actionNodes.count  }
		
		actionNodes.insert(node, at:indexToInsertNode)
		
		node.leftTransitionNode = nil
		node.rightTransitionNode = nil
		
		if actionNodes.count == 1 { return }
		
		if indexToInsertNode > 0 { addTransistionNodeToActionNodes(actionNodes[indexToInsertNode-1], right:node) }
		if indexToInsertNode < actionNodes.count-1 { addTransistionNodeToActionNodes(node, right:actionNodes[indexToInsertNode+1]) }
	}
	
	
	func removeActionNode(_ node:Node) {
		
		let index = actionNodes.index(of: node)
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
		
		if index! == actionNodes.count {
			transitionNodes.removeObject(actionNodes[actionNodes.count-1].rightTransitionNode!)
			actionNodes[actionNodes.count-1].rightTransitionNode = nil
			return
		}
		
		// it's in the middle of two others
		
		addTransistionNodeToActionNodes(actionNodes[index!-1], right: actionNodes[index!])
	}
	
	
	func forceCreateTransistionNodesForActionNodes() {
		
		if actionNodes.count == 0 {return}
		
		if actionNodes.count == 1 {
			actionNodes[0].leftTransitionNode = nil
			actionNodes[0].rightTransitionNode = nil
			return;
		}
		
		for index in 0  ..< actionNodes.count-1  {
			//  if actionNodes[index].rightTransitionNode === nil {
			addTransistionNodeToActionNodes(actionNodes[index], right:actionNodes[index+1])
			// }
			//  if index > 0  && actionNodes[index].leftTransitionNode === nil {
			// }
		}
	}
	
	
	fileprivate func addTransistionNodeToActionNodes(_ left: Node, right: Node) {
		
		/// we need to delete transition node from array if we break any transitions
		/// Could return the deleted ones if we need to be notified about that...
		
		if left.rightTransitionNode != nil { transitionNodes.removeObject(left.rightTransitionNode!) }
		if right.leftTransitionNode != nil { transitionNodes.removeObject(right.leftTransitionNode!) }
		let name = ""
		//	let name = left.title + " -> " + right.title
		let transitionNode = Node(text: name, type: [.Transition], rules: nil)
		left.rightTransitionNode = transitionNode
		right.leftTransitionNode = transitionNode
		transitionNodes.append(transitionNode)
	}
	
	
	func printChain() {
		for node in nodeChain() { print (String(describing: node.type) + ": " + node.title) }
		validSequence() ? print("Sequence is Valid") : print("Sequence is NOT Valid")
	}
	
	
	// MARK: Position in sequence
	
	enum NodePostion {
		case startingAction
		case transition
		case action
		case endingAction
		case none
	}
	
	func calculateActionNodePosition(_ node: Node) -> NodePostion {
		let index = actionNodes.index(of: node)
		guard index != nil else { return .none}
		guard node.type == .Action else { return .transition }
		
		var result: NodePostion
		
		switch self.timeDirection {
		case .forward:
			switch Int(index!) {
			case 0: result = .startingAction
			case let x where x == actionNodes.count-1: result = .endingAction
			case let x where x.isEven(): result = .action
			default: result = .action // .Transaction
			}
			
		case .backward:
			switch Int(index!) {
			case 0: result = .endingAction
			case let x where x == actionNodes.count-1: result = .startingAction
			case let x where x.isEven(): result = .action
			default: result = .action // .Transaction
			}
		}
		return result
	}
}
