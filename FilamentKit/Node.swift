//
//  Node.swift
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2015 Andris Ltd. All rights reserved.
//

import Foundation

public class Node: NSObject, NSCoding, NSCopying {
    
    /** 
    
    FINode is either an Action, or a Transition.  
    
    Each node has an array of rules.
    
    */
    
    public enum Type: Int {
        
        case Action = 0, Transition, NestedSequence, None
        
        private var name: String {
            switch self {
            case .Action:           return "Action"
            case .Transition:       return "Transition"
            case .NestedSequence:   return "Nested Sequence"   //TODO: Nested Seq
            case .None:             return "None"
            }
        }
        
        // MARK: Printable
        
        public var description: String {
            return name
        }
    }
    
    
    // MARK: Properties
    
    public var text: String
    public var rules = [Rule]()
    public var type: Type
    public var leftTransitionNode: Node?
    public var rightTransitionNode: Node?
    private var UUID: NSUUID
    
    
    // MARK: Initializers
    
    public init(text: String, type: Type = .Action, rules:[Rule]?) {
        
        self.text = text
        self.type = type
        self.UUID = NSUUID()
        
        if let incomingRules = rules {
            self.rules = incomingRules.map { $0.copy() as! Rule }
        }
        
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
        type = Type(rawValue: aDecoder.decodeIntegerForKey(SerializationKeys.type))!
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
    
    
    // MARK: Equality
    
    /*
    override public func isEqual(object: AnyObject) -> Bool {
        
        if let node = object as? Node {
            if text != node.text || type != node.type  {
                return false
            }
            
            return rules == node.rules
        }
        
        return false
    }
*/
}