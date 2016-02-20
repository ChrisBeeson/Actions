//
//  Node.swift
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

 enum NodeType: Int { case Action = 0, Transition, All, None }

 class Node: NSObject, NSCoding {
    
     var title = ""
     var notes = ""
     var rules = [Rule]()
     var type = NodeType.Action
     var leftTransitionNode: Node?
     var rightTransitionNode: Node?
     var UUID = NSUUID()
     var event: Event?
    
    // MARK: Initializers
    
     init(text: String, type: NodeType = .Action, rules:[Rule]?) {
        
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
    
    
     override init() {
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
        static let event = "event"
    }
    
     required init?(coder aDecoder: NSCoder) {
        
        super.init()
        
        title = aDecoder.decodeObjectForKey(SerializationKeys.title) as! String
        notes = aDecoder.decodeObjectForKey(SerializationKeys.notes) as! String
        rules = aDecoder.decodeObjectForKey(SerializationKeys.rules) as! [Rule]
        type = NodeType(rawValue: aDecoder.decodeIntegerForKey(SerializationKeys.type))!
        UUID = aDecoder.decodeObjectForKey(SerializationKeys.uuid) as! NSUUID
        leftTransitionNode = aDecoder.decodeObjectForKey(SerializationKeys.leftTransitionNode) as? Node
        rightTransitionNode = aDecoder.decodeObjectForKey(SerializationKeys.rightTransitionNode) as? Node
        event = aDecoder.decodeObjectForKey(SerializationKeys.event) as? Event
        
        if event != nil {
            event!.owner = self
            event!.synchronizeCalendarEvent()
        }
    }

     func encodeWithCoder(encoder: NSCoder) {
        
        encoder.encodeObject(title, forKey: SerializationKeys.title)
        encoder.encodeObject(notes, forKey: SerializationKeys.notes)
        encoder.encodeObject(rules, forKey: SerializationKeys.rules)
        encoder.encodeInteger(type.rawValue, forKey: SerializationKeys.type)
        encoder.encodeObject(UUID, forKey: SerializationKeys.uuid)
        encoder.encodeObject(leftTransitionNode, forKey: SerializationKeys.leftTransitionNode)
        encoder.encodeObject(rightTransitionNode, forKey: SerializationKeys.rightTransitionNode)
        encoder.encodeObject(event, forKey: SerializationKeys.event)
    }
    
    
    // MARK: NSCopying
    
     func copyWithZone(zone: NSZone) -> AnyObject  {
        
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
    
    override  func isEqual(object: AnyObject?) -> Bool {
        
        if let node = object as? Node {
            if UUID == node.UUID  {
                return true
            }
            return false
        }
        return false
    }
    
    
    //MARK: Event Creation and Maintance
    
    func setEventPeriod(period: DTTimePeriod) {
        
        if event == nil {
            event = Event(period:period, owner: self)
        } else {
            event!.period = period
        }
    }
    
   func deleteEvent() {
        if self.event == nil { return }
        self.event!.deleteCalenderEvent()
    }
    
    
    
    // Description

     override var description: String {
        return " \(self.title) type: \(type) \n Rules: \n \(rules)"
    }
}