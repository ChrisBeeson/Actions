//
//  Sequence.swift
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2015 Andris Ltd. All rights reserved.
//

import Foundation

public class Sequence: NSObject, NSCopying, NSCoding {
    
    /**
        A sequence is formed from action and transition nodes.
    
        Action -> Transition -> Action -> Transition -> Action
    
        Transitions can only sit inbetween Action nodes
    */
    
    
    // MARK: Properties
    
    public var name: String
    public var actionNodes = [Node]()
    public var transistionNodes = [Node]()
    
    public var instances = [SequenceInstance]()
    
    
    // MARK: Initializers
    
    public init(name:String, actionNodes:[Node]? = []) {
        
        self.name = name
        
        if let nodes = actionNodes {
        
            self.actionNodes = nodes.map { $0.copy() as! Node}
        }
    }
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        static let name = "name"
        static let actionNodes = "actionNodes"
        static let transistionNodes = "transitionNodes"
        static let instances = "instances"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        actionNodes = aDecoder.decodeObjectForKey(SerializationKeys.actionNodes) as! [Node]
        transistionNodes = aDecoder.decodeObjectForKey(SerializationKeys.transistionNodes) as! [Node]
        name = aDecoder.decodeObjectForKey(SerializationKeys.name) as! String
        instances = aDecoder.decodeObjectForKey(SerializationKeys.instances) as! [SequenceInstance]
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(actionNodes, forKey: SerializationKeys.actionNodes)
        aCoder.encodeObject(transistionNodes, forKey: SerializationKeys.transistionNodes)
        aCoder.encodeObject(name, forKey: SerializationKeys.name)
        aCoder.encodeObject(instances, forKey: SerializationKeys.instances)
    }
    
    // MARK: NSCopying
    
    public func copyWithZone(zone: NSZone) -> AnyObject  {
        
        return Sequence(name:name, actionNodes:actionNodes, transistionNodes:transistionNodes, instances:instances)
    }
    
    
    // MARK: Methods
    
    public func allNodes() -> [Node] {
        
        updateTransitionNodes()
        
        var nodesToReturn = [Node]()
        
        for node in actionNodes {
            
            nodesToReturn.append(node)
            
            if node.rightTransitionNode != nil {
                
                nodesToReturn.append(node.rightTransitionNode!)
            }
        }
        
        return nodesToReturn
    }
    
    
    private func updateTransitionNodes() {
        
        if actionNodes.count == 0 {return}
        
        if actionNodes.count == 1 {
            actionNodes[0].leftTransitionNode = nil
            actionNodes[0].rightTransitionNode = nil
            return;
        }
        
        for var index = 0 ; index < actionNodes.count ; ++index {
            
            if actionNodes[index].rightTransitionNode === nil {
                
                let name = actionNodes[index].text + " -> " + actionNodes[index+1].text
                
                let transitionNode = Node(text: name, type: .Transition, rules: nil)
               
                actionNodes[index].rightTransitionNode = transitionNode
                actionNodes[index+1].leftTransitionNode = transitionNode
                
                transistionNodes.append(transitionNode)
            }
        }
    }
    
}