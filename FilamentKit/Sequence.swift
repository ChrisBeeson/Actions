//
//  Sequence.swift
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2016 Andris Ltd. All rights reserved.
//

import Foundation

@objc
public enum TimeDirection: Int {
    case Forward
    case Backward
}

class Sequence: NSObject, NSCopying, NSCoding {
    
    var title: String = ""
    var actionNodes = [Node]()
    var transitionNodes = [Node]()
    var date: NSDate?
    var timeDirection = TimeDirection.Forward
    var generalRules = [Rule]()
    var uuid = NSUUID()

    // MARK: Initializers
    override init () {
        super.init()
    }
    
     init(name:String, actionNodes:[Node]? = []) {
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
        static let timeDirection = "timeDirection"
        static let events = "events"
        static let uuid = "uuid"
        static let generalRules = "generalRules"
    }
    
     required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObjectForKey(SerializationKeys.title) as! String
        actionNodes = aDecoder.decodeObjectForKey(SerializationKeys.actionNodes) as! [Node]
        transitionNodes = aDecoder.decodeObjectForKey(SerializationKeys.transitionNodes) as! [Node]
        date = aDecoder.decodeObjectForKey(SerializationKeys.date) as? NSDate
        timeDirection = TimeDirection(rawValue: aDecoder.decodeIntegerForKey(SerializationKeys.timeDirection))!
        uuid = aDecoder.decodeObjectForKey(SerializationKeys.uuid) as! NSUUID
        generalRules = aDecoder.decodeObjectForKey(SerializationKeys.generalRules) as! [Rule]
    }
    
     func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: SerializationKeys.title)
        aCoder.encodeObject(actionNodes, forKey: SerializationKeys.actionNodes)
        aCoder.encodeObject(transitionNodes, forKey: SerializationKeys.transitionNodes)
        aCoder.encodeObject(date, forKey: SerializationKeys.date)
        aCoder.encodeInteger(timeDirection.rawValue, forKey: SerializationKeys.timeDirection)
        aCoder.encodeObject(uuid, forKey: SerializationKeys.uuid)
        aCoder.encodeObject(generalRules, forKey: SerializationKeys.generalRules)
    }
    
    // MARK: NSCopying
     func copyWithZone(zone: NSZone) -> AnyObject  {
        let clone = Sequence()
        clone.title = title.copy() as! String
        clone.actionNodes =  NSArray(array:actionNodes, copyItems: true) as! [Node]
        clone.transitionNodes = NSArray(array:transitionNodes, copyItems: true) as! [Node]
        clone.date = date
        clone.timeDirection = timeDirection
        clone.generalRules =  NSArray(array:generalRules, copyItems: true) as! [Rule]
        return clone
    }
    
     var filename: String {
        var filename = uuid.UUIDString
        filename.appendContentsOf("."+AppConfiguration.applicationFileExtension)
        return filename
    }
    
    // Description
     override var description: String {
        return " \(title)"
    }
    
    // MARK: Equality
    override  func isEqual(object: AnyObject?) -> Bool {
        if let sequence = object as? Sequence {
            if uuid == sequence.uuid  {
                return true
            }
            return false
        }
        return false
    }
}
