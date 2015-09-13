//
//  Node.swift
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2015 Andris Ltd. All rights reserved.
//

import Foundation

public class Node: NSObject, NSCoding, NSCopying {
    
    public enum NodeType: Int { case Action = 0, Transition, All, None }
    
    // MARK: Properties
    
    public var text = ""
    public var rules = [Rule]()
    public var type = NodeType.Action
    public var leftTransitionNode: Node?
    public var rightTransitionNode: Node?
    public var UUID = NSUUID()
    
    
    // MARK: Initializers
    
    public init(text: String, type: NodeType = .Action, rules:[Rule]?) {
        
        self.text = text
        self.type = type
        
        if let incomingRules = rules {
            
            self.rules = incomingRules.map { $0.copy() as! Rule }
        }
        
        if type == .Action {
            self.rules.append(DurationRule())
        }
        
        super.init()
    }
    
    public override init() {
        
        super.init()
    }
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        static let text = "text"
        static let rules = "rules"
        static let type = "type"
        static let uuid = "uuid"
        static let leftTransitionNode = "leftTransitionNode"
        static let rightTransitionNode = "rightTransitionNode"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        text = aDecoder.decodeObjectForKey(SerializationKeys.text) as! String
        rules = aDecoder.decodeObjectForKey(SerializationKeys.rules) as! [Rule]
        type = NodeType(rawValue: aDecoder.decodeIntegerForKey(SerializationKeys.type))!
        UUID = aDecoder.decodeObjectForKey(SerializationKeys.uuid) as! NSUUID
        leftTransitionNode = aDecoder.decodeObjectForKey(SerializationKeys.leftTransitionNode) as? Node
        rightTransitionNode = aDecoder.decodeObjectForKey(SerializationKeys.rightTransitionNode) as? Node
    }
    
    public func encodeWithCoder(encoder: NSCoder) {
        
        encoder.encodeObject(text, forKey: SerializationKeys.text)
        encoder.encodeObject(rules, forKey: SerializationKeys.rules)
        encoder.encodeInteger(type.rawValue, forKey: SerializationKeys.type)
        encoder.encodeObject(UUID, forKey: SerializationKeys.uuid)
        encoder.encodeObject(leftTransitionNode, forKey: SerializationKeys.leftTransitionNode)
        encoder.encodeObject(rightTransitionNode, forKey: SerializationKeys.rightTransitionNode)
    }
    
    
    // MARK: NSCopying
    
    public func copyWithZone(zone: NSZone) -> AnyObject  {
        return Node(text: text, type: type, rules: rules)
    }
    
    public func instance(name: String) -> NodeInstance {
        
        let instance =  NodeInstance()
        instance.text = text
        instance.type = type
        instance.rules =  NSArray(array:rules, copyItems: true) as! [Rule]
        instance.UUID = UUID
        
        return instance
    }
    
    // MARK: Equality
    
    
    override public func isEqual(object: AnyObject?) -> Bool {
        
        if let node = object as? Node {
            if UUID != node.UUID  {
                return false
            }
            
            return rules == node.rules
        }
        
        return false
    }
    
}