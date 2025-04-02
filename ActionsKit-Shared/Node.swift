//
//  Node.swift
//  Actions
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools
import ObjectMapper

public struct NodeType : OptionSet {
    
    public let rawValue : Int
    public init(rawValue:Int){ self.rawValue = rawValue}
    
    static public let Void = NodeType (rawValue:0)
    static public let Action = NodeType (rawValue:1)
    static public let Transition = NodeType (rawValue:2)
    static public let Generic = NodeType (rawValue:4)
}


class Node: NSObject, NSCoding, Mappable {
    
    var title = ""
    var notes = ""
    var location = ""
    var rules = [Rule]()
    var type:NodeType = [.Action]
    var leftTransitionNode: Node?
    var rightTransitionNode: Node?
    var UUID:String = Foundation.UUID().uuidString
    var event: CalendarEvent?
    var isCompleted = false
    
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
    
    fileprivate struct SerializationKeys {
        static let title = "title"
        static let notes = "notes"
        static let location = "location"
        static let rules = "rules"
        static let type = "type"
        static let uuid = "uuid"
        static let leftTransitionNode = "leftTransitionNode"
        static let rightTransitionNode = "rightTransitionNode"
        static let event = "event"
        static let isCompleted = "isCompleted"
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init()
        
        title = aDecoder.decodeObject(forKey: SerializationKeys.title) as! String
        notes = aDecoder.decodeObject(forKey: SerializationKeys.notes) as! String
        location = aDecoder.decodeObject(forKey: SerializationKeys.location) as! String
        rules = aDecoder.decodeObject(forKey: SerializationKeys.rules) as! [Rule]
        type = NodeType(rawValue: aDecoder.decodeInteger(forKey: SerializationKeys.type))
        UUID = aDecoder.decodeObject(forKey: SerializationKeys.uuid) as! String
        leftTransitionNode = aDecoder.decodeObject(forKey: SerializationKeys.leftTransitionNode) as? Node
        rightTransitionNode = aDecoder.decodeObject(forKey: SerializationKeys.rightTransitionNode) as? Node
        event = aDecoder.decodeObject(forKey: SerializationKeys.event) as? CalendarEvent
        isCompleted = aDecoder.decodeObject(forKey: SerializationKeys.isCompleted) as! Bool
        
        if event != nil { event!.owner = self }
    }
    
    func encode(with encoder: NSCoder) {
        
        encoder.encode(title, forKey: SerializationKeys.title)
        encoder.encode(notes, forKey: SerializationKeys.notes)
        encoder.encode(location, forKey: SerializationKeys.location)
        encoder.encode(rules, forKey: SerializationKeys.rules)
        encoder.encode(type.rawValue, forKey: SerializationKeys.type)
        encoder.encode(UUID, forKey: SerializationKeys.uuid)
        encoder.encode(leftTransitionNode, forKey: SerializationKeys.leftTransitionNode)
        encoder.encode(rightTransitionNode, forKey: SerializationKeys.rightTransitionNode)
        encoder.encode(event, forKey: SerializationKeys.event)
        encoder.encode(isCompleted, forKey: SerializationKeys.isCompleted)
    }
    
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(_ map: Map) {
        title                   <- map[SerializationKeys.title]
        notes                   <- map[SerializationKeys.notes]
        location                <- map[SerializationKeys.location]
        rules                   <- map[SerializationKeys.rules]
        type                    <- (map[SerializationKeys.type], EnumTransform())
        UUID                    <- map[SerializationKeys.uuid]
        leftTransitionNode      <- map[SerializationKeys.leftTransitionNode]
        rightTransitionNode     <- map[SerializationKeys.rightTransitionNode]
        event                   <- map[SerializationKeys.event]
        isCompleted             <- map[SerializationKeys.isCompleted]
    }
    
    
    // MARK: NSCopying
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject  {
        
        //TODO: can't copy transistions nodes from here as they are meaningless
        
        let clone = Node(text: title, type: type, rules: rules)
        clone.notes = notes.copy() as! String
        clone.location = location.copy() as! String
        clone.event  = event?.copy() as? CalendarEvent
        clone.UUID = UUID.copy() as! String
        clone.rules = rules
        clone.leftTransitionNode = leftTransitionNode
        clone.rightTransitionNode = rightTransitionNode
        return clone
    }
    
    
    // MARK: Equality
    
    override func isEqual(_ object: Any?) -> Bool {
        if let node = object as? Node {
            if UUID == node.UUID  {
                return true
            }
            return false
        }
        return false
    }
    
    
    //MARK: CalendarEvent Creation and Maintance
    
    func setEventPeriod(_ period: DTTimePeriod) {
        if event == nil {
            self.event = CalendarEvent(period:period, owner: self)
        } else {
            if period.isEqual(to: event!.period) == false {
            event!.period = period
            }
        }
    }
    
    func deleteEvent() {
        if self.event == nil { return }
        self.event!.deleteCalenderEvent()
        self.event?.owner = nil
        self.event = nil
    }
    
    
    // Description
    
    override var description: String {
        return " \(self.title) type: \(type) \n Rules: \n \(rules)"
    }
}
