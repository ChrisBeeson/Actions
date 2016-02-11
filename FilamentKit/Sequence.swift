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
    var actionNodes = [Node]()
    var transitionNodes = [Node]()
    public var date: NSDate?
    public var startsAtDate = true    // false means the sequence is back timed to end at the date
    var uuid = NSUUID()

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
        static let date = "date"
        static let startsAtDate = "startsAtDate"
        static let events = "events"
        static let uuid = "uuid"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObjectForKey(SerializationKeys.title) as! String
        actionNodes = aDecoder.decodeObjectForKey(SerializationKeys.actionNodes) as! [Node]
        transitionNodes = aDecoder.decodeObjectForKey(SerializationKeys.transitionNodes) as! [Node]
        date = aDecoder.decodeObjectForKey(SerializationKeys.date) as? NSDate
        startsAtDate = aDecoder.decodeObjectForKey(SerializationKeys.startsAtDate) as! Bool
        uuid = aDecoder.decodeObjectForKey(SerializationKeys.uuid) as! NSUUID
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: SerializationKeys.title)
        aCoder.encodeObject(actionNodes, forKey: SerializationKeys.actionNodes)
        aCoder.encodeObject(transitionNodes, forKey: SerializationKeys.transitionNodes)
        aCoder.encodeObject(date, forKey: SerializationKeys.date)
        aCoder.encodeObject(startsAtDate, forKey: SerializationKeys.startsAtDate)
        aCoder.encodeObject(uuid, forKey: SerializationKeys.uuid)
    }
    
    
    // MARK: NSCopying
    
    public func copyWithZone(zone: NSZone) -> AnyObject  {
        let clone = Sequence()
        clone.title = title.copy() as! String
        clone.actionNodes =  NSArray(array:actionNodes, copyItems: true) as! [Node]
        clone.transitionNodes = NSArray(array:transitionNodes, copyItems: true) as! [Node]
        clone.date = date
        clone.startsAtDate = startsAtDate
        return clone
    }
    
    public var filename: String {
        var filename = uuid.UUIDString
        filename.appendContentsOf("."+AppConfiguration.filamentFileExtension)
        return filename
    }
    
    // Description
    
    public override var description: String {
        return " \(title)"
    }
    
    // MARK: Equality
    
    override public func isEqual(object: AnyObject?) -> Bool {
        if let sequence = object as? Sequence {
            if uuid == sequence.uuid  {
                return true
            }
            return false
        }
        return false
    }
}
