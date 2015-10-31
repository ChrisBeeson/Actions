//
//  Sequence.swift
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2015 Andris Ltd. All rights reserved.
//

import Foundation

public class Sequence: NSObject, NSCopying, NSCoding {
    
    public var title: String = ""
    public var actionNodes = [Node]()
    public var transitionNodes = [Node]()
    public var startDate: NSDate?
    public var UUID = NSUUID()

    // public var calendarsToAvoid = [EKCalendar]()
    
    
    // MARK: Initializers
    
    override public init () {
        super.init()
    }
    
    public init(name:String, actionNodes:[Node]? = []) {
        
        self.title = name
        super.init()
        
        if let nodes = actionNodes {
            self.actionNodes = nodes.map { $0.copy() as! Node}
            forceCreateTransistionNodesForActionNodes()
        }
    }
    
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        
        static let title = "title"
        static let actionNodes = "actionNodes"
        static let transitionNodes = "transitionNodes"
        static let startDate = "startDate"
        static let events = "events"
        static let uuid = "uuid"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        title = aDecoder.decodeObjectForKey(SerializationKeys.title) as! String
        actionNodes = aDecoder.decodeObjectForKey(SerializationKeys.actionNodes) as! [Node]
        transitionNodes = aDecoder.decodeObjectForKey(SerializationKeys.transitionNodes) as! [Node]
        startDate = aDecoder.decodeObjectForKey(SerializationKeys.startDate) as? NSDate
        UUID = aDecoder.decodeObjectForKey(SerializationKeys.uuid) as! NSUUID
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(title, forKey: SerializationKeys.title)
        aCoder.encodeObject(actionNodes, forKey: SerializationKeys.actionNodes)
        aCoder.encodeObject(transitionNodes, forKey: SerializationKeys.transitionNodes)
        aCoder.encodeObject(startDate, forKey: SerializationKeys.startDate)
        aCoder.encodeObject(UUID, forKey: SerializationKeys.uuid)
    }
    
    
    // MARK: NSCopying
    
    public func copyWithZone(zone: NSZone) -> AnyObject  {
        
        let clone = Sequence()
        clone.title = title.copy() as! String
        clone.actionNodes =  NSArray(array:actionNodes, copyItems: true) as! [Node]
        clone.transitionNodes = NSArray(array:transitionNodes, copyItems: true) as! [Node]
        return clone
    }
    
    // Description
    
    public override var description: String {
        
        return " \(title)"
    }
    
    // MARK: Equality
    
    override public func isEqual(object: AnyObject?) -> Bool {
        
        if let sequence = object as? Sequence {
            if UUID == sequence.UUID  {
                return true
            }
            return false
        }
        return false
    }
}
