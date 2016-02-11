//
//  Node.swift
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2015 Andris Ltd. All rights reserved.
//

import Foundation
import EventKit

public enum NodeType: Int { case Action = 0, Transition, All, None }

public class Node: NSObject, NSCoding {
    
    public var title = ""
    public var rules = [Rule]()
    public var type = NodeType.Action
    public var leftTransitionNode: Node?
    public var rightTransitionNode: Node?
    public var UUID = NSUUID()
    public var event: EKEvent?
    
    
    // MARK: Initializers
    
    public init(text: String, type: NodeType = .Action, rules:[Rule]?) {
        
        self.title = text
        self.type = type
        
        /*
        if let nodes = actionNodes {
            self.actionNodes = nodes.map { $0.copy() as! Node}
        }
        */
        
        if let incomingRules = rules {
            for rule in incomingRules { self.rules.append(rule) }    // Could be a problem as we are not copying..
        }
        
        // Add default rules
        
        switch type {
            case .Action: self.rules.append(EventDuration())
            case .Transition: self.rules.append(EventStartsInTimeFromNow())
            default: break
        }
        
        super.init()
    }
    
    
    public override init() {
        super.init()
    }
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        static let title = "title"
        static let rules = "rules"
        static let type = "type"
        static let uuid = "uuid"
        static let leftTransitionNode = "leftTransitionNode"
        static let rightTransitionNode = "rightTransitionNode"
        static let event = "event"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        title = aDecoder.decodeObjectForKey(SerializationKeys.title) as! String
        rules = aDecoder.decodeObjectForKey(SerializationKeys.rules) as! [Rule]
        type = NodeType(rawValue: aDecoder.decodeIntegerForKey(SerializationKeys.type))!
        UUID = aDecoder.decodeObjectForKey(SerializationKeys.uuid) as! NSUUID
        leftTransitionNode = aDecoder.decodeObjectForKey(SerializationKeys.leftTransitionNode) as? Node
        rightTransitionNode = aDecoder.decodeObjectForKey(SerializationKeys.rightTransitionNode) as? Node
        event = aDecoder.decodeObjectForKey(SerializationKeys.event) as? EKEvent
    }

    public func encodeWithCoder(encoder: NSCoder) {
        
        encoder.encodeObject(title, forKey: SerializationKeys.title)
        encoder.encodeObject(rules, forKey: SerializationKeys.rules)
        encoder.encodeInteger(type.rawValue, forKey: SerializationKeys.type)
        encoder.encodeObject(UUID, forKey: SerializationKeys.uuid)
        encoder.encodeObject(leftTransitionNode, forKey: SerializationKeys.leftTransitionNode)
        encoder.encodeObject(rightTransitionNode, forKey: SerializationKeys.rightTransitionNode)
        encoder.encodeObject(event, forKey: SerializationKeys.event)
    }
    
    
    // MARK: NSCopying
    
    public func copyWithZone(zone: NSZone) -> AnyObject  {
        
        return Node(text: title, type: type, rules: rules)
    }
    
    
    // MARK: Equality
    
    override public func isEqual(object: AnyObject?) -> Bool {
        
        if let node = object as? Node {
            if UUID == node.UUID  {
                return true
            }
            
            return false
        }
        
        return false
    }
    
    // Description

    public override var description: String {
        
        return " \(self.title) type: \(type) \n Rules: \n \(rules)"
    }
}