//
//  Node.swift
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2016 Andris Ltd. All rights reserved.
//

import Foundation
import EventKit

public enum NodeType: Int { case Action = 0, Transition, All, None }

public class Node: NSObject, NSCoding {
    
    public var title = ""
    public var notes = ""
    public var rules = [Rule]()
    public var type = NodeType.Action
    public var leftTransitionNode: Node?
    public var rightTransitionNode: Node?
    public var UUID = NSUUID()
    public var event: Event?
    
    // MARK: Initializers
    
    public init(text: String, type: NodeType = .Action, rules:[Rule]?) {
        
        self.title = text
        self.type = type
        
        if let incomingRules = rules {
            for rule in incomingRules { self.rules.append(rule) }
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
        static let notes = "notes"
        static let rules = "rules"
        static let type = "type"
        static let uuid = "uuid"
        static let leftTransitionNode = "leftTransitionNode"
        static let rightTransitionNode = "rightTransitionNode"
        static let eventID = "eventIdentifier"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        title = aDecoder.decodeObjectForKey(SerializationKeys.title) as! String
        notes = aDecoder.decodeObjectForKey(SerializationKeys.notes) as! String
        rules = aDecoder.decodeObjectForKey(SerializationKeys.rules) as! [Rule]
        type = NodeType(rawValue: aDecoder.decodeIntegerForKey(SerializationKeys.type))!
        UUID = aDecoder.decodeObjectForKey(SerializationKeys.uuid) as! NSUUID
        leftTransitionNode = aDecoder.decodeObjectForKey(SerializationKeys.leftTransitionNode) as? Node
        rightTransitionNode = aDecoder.decodeObjectForKey(SerializationKeys.rightTransitionNode) as? Node
        eventID = aDecoder.decodeObjectForKey(SerializationKeys.eventID) as! String
    }

    public func encodeWithCoder(encoder: NSCoder) {
        
        encoder.encodeObject(title, forKey: SerializationKeys.title)
        encoder.encodeObject(notes, forKey: SerializationKeys.notes)
        encoder.encodeObject(rules, forKey: SerializationKeys.rules)
        encoder.encodeInteger(type.rawValue, forKey: SerializationKeys.type)
        encoder.encodeObject(UUID, forKey: SerializationKeys.uuid)
        encoder.encodeObject(leftTransitionNode, forKey: SerializationKeys.leftTransitionNode)
        encoder.encodeObject(rightTransitionNode, forKey: SerializationKeys.rightTransitionNode)
        encoder.encodeObject(eventID, forKey: SerializationKeys.eventID)
    }
    
    
    // MARK: NSCopying
    
    public func copyWithZone(zone: NSZone) -> AnyObject  {
        
        //TODO: can't copy transistions nodes from here as they are meaningless
        
        let clone = Node(text: title, type: type, rules: rules)
        clone.notes = notes.copy() as! String
        clone.UUID = UUID.copy() as! NSUUID
        // clone.event  = event!.copy() as? EKEvent
        clone.leftTransitionNode = leftTransitionNode
        clone.rightTransitionNode = rightTransitionNode
        return clone
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