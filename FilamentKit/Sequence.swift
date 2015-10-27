//
//  Sequence.swift
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2015 Andris Ltd. All rights reserved.
//

import Foundation

public class Sequence: NSObject, NSCopying, NSCoding {
    
    // MARK: Properties
    
    public var name: String = ""
    public var actionNodes = [Node]()
    public var transitionNodes = [Node]()
    public var instances = [Instance]()
    
    
    // MARK: Initializers
    
    override public init () {
        super.init()
    }
    
    public init(name:String, actionNodes:[Node]? = []) {
        
        self.name = name
        super.init()
        
        if let nodes = actionNodes {
            self.actionNodes = nodes.map { $0.copy() as! Node}
            forceCreateTransistionNodesForActionNodes()
        }
    }
    
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        
        static let name = "name"
        static let actionNodes = "actionNodes"
        static let transitionNodes = "transitionNodes"
        static let instances = "instances"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        actionNodes = aDecoder.decodeObjectForKey(SerializationKeys.actionNodes) as! [Node]
        transitionNodes = aDecoder.decodeObjectForKey(SerializationKeys.transitionNodes) as! [Node]
        name = aDecoder.decodeObjectForKey(SerializationKeys.name) as! String
        instances = aDecoder.decodeObjectForKey(SerializationKeys.instances) as! [Instance]
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(actionNodes, forKey: SerializationKeys.actionNodes)
        aCoder.encodeObject(transitionNodes, forKey: SerializationKeys.transitionNodes)
        aCoder.encodeObject(name, forKey: SerializationKeys.name)
        aCoder.encodeObject(instances, forKey: SerializationKeys.instances)
    }
    
    
    // MARK: NSCopying
    
    public func copyWithZone(zone: NSZone) -> AnyObject  {
        
        let clone = Sequence()
        clone.name = name.copy() as! String
        clone.actionNodes =  NSArray(array:actionNodes, copyItems: true) as! [Node]
        clone.transitionNodes = NSArray(array:transitionNodes, copyItems: true) as! [Node]
        clone.instances = NSArray(array:instances, copyItems: true) as! [Instance]
        return clone
    }
    
    
    
    // MARK: Methods
    
    public func allNodes() -> [Node] {
        
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
        
        let nodes = allNodes()
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
    
    
    public func logAllNodes() {
        
        for node in allNodes() { print (String(node.type) + ": " + node.text) }
        validSequence() ? NSLog("Sequence is Valid") : NSLog("Sequence is NOT Valid")
    }
    
    
    public func newInstance(startDate: NSDate) -> Instance {    // Sequence owns this.. The name is confusing.
        
        let instance = Instance(startDate: startDate, sequence: self)
        instances.append(instance)
        return instance
    }
    
    
    // MARK: Private functions
    
    private func forceCreateTransistionNodesForActionNodes() {
        
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
        
        let name = left.text + " -> " + right.text
        let transitionNode = Node(text: name, type: .Transition, rules: nil)
        
        left.rightTransitionNode = transitionNode
        right.leftTransitionNode = transitionNode
        
        transitionNodes.append(transitionNode)
    }
}


// MARK: Extensions


extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

extension IntegerType {
    
    func isEven() -> Bool {
        
        return self % 2 == 0 ? true : false
    }
}
