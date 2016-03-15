//
//  Node.swift
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

public struct NodeType : OptionSetType {
    
    public let rawValue : Int
    public init(rawValue:Int){ self.rawValue = rawValue}
    
    static public let Void = NodeType (rawValue:0)
    static public let Action = NodeType (rawValue:1)
    static public let Transition = NodeType (rawValue:2)
    static public let Generic = NodeType (rawValue:4)
}


class Node: NSObject, NSCoding {
    
    var title = ""
    var notes = ""
    var location = ""
    var rules = [Rule]()
    var type:NodeType = [.Action]
    var leftTransitionNode: Node?
    var rightTransitionNode: Node?
    var UUID = NSUUID()
    var event: TimeEvent?
    
    // MARK: Initializers
    
    init(text: String, type: NodeType = [.Action], rules:[Rule]?) {
        
        self.title = text
        self.type = type
        
        if let incomingRules = rules {
            for rule in incomingRules { self.rules.append(rule) }
        }
        
        // Add default rules if there arn't any already
        
        if self.rules.count == 0 {
            
            switch type {
                
            case [.Action]:
                self.rules.append(EventDurationWithMinimumDuration ())
                
            case [.Transition]:
                self.rules.append(TransitionDurationWithVariance())
                
            default: break
            }
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
        static let location = "location"
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
        location = aDecoder.decodeObjectForKey(SerializationKeys.location) as! String
        rules = aDecoder.decodeObjectForKey(SerializationKeys.rules) as! [Rule]
        type = NodeType(rawValue: aDecoder.decodeIntegerForKey(SerializationKeys.type))
        UUID = aDecoder.decodeObjectForKey(SerializationKeys.uuid) as! NSUUID
        leftTransitionNode = aDecoder.decodeObjectForKey(SerializationKeys.leftTransitionNode) as? Node
        rightTransitionNode = aDecoder.decodeObjectForKey(SerializationKeys.rightTransitionNode) as? Node
        event = aDecoder.decodeObjectForKey(SerializationKeys.event) as? TimeEvent
        
        if event != nil {
            event!.owner = self
            event!.synchronizeCalendarEvent()
        }
    }
    
    func encodeWithCoder(encoder: NSCoder) {
        
        encoder.encodeObject(title, forKey: SerializationKeys.title)
        encoder.encodeObject(notes, forKey: SerializationKeys.notes)
        encoder.encodeObject(location, forKey: SerializationKeys.location)
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
        clone.location = location.copy() as! String
        clone.UUID = UUID.copy() as! NSUUID
        clone.event  = event?.copy() as? TimeEvent
        //     for rule in rules { clone.rules.append(rule) }
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
    
    
    //MARK: TimeEvent Creation and Maintance
    
    func setEventPeriod(period: DTTimePeriod) {
        
        if event == nil {
            event = TimeEvent(period:period, owner: self)
        } else {
            event!.period = period
        }
    }
    
    func deleteEvent() {
        if self.event == nil { return }
        self.event!.deleteCalenderEvent()
        self.event = nil
    }
    
    
    
    // Description
    
    override var description: String {
        return " \(self.title) type: \(type) \n Rules: \n \(rules)"
    }
}