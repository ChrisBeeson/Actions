//
//  Sequence.swift
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2015 Andris Ltd. All rights reserved.
//

import Foundation

public class Sequence: NSObject, NSCopying, NSCoding {
    
    public var name: String = ""
    public var actionNodes = [Node]()
    public var transitionNodes = [Node]()
    public var startDate: NSDate?
    
    private var events = [Event]()
    
    // public var calendarsToAvoid = [EKCalendar]()
    
    
    // MARK: Initializers
    
    override public init () {
        super.init()
    }
    
    public init(name:String, actionNodes:[Node]? = []) {
        
        self.name = name
        super.init()
        
        if let nodes = actionNodes {
            self.actionNodes = nodes.map { $0.copy() as! Node}
            forceCreateTransistionNodesForActionNodes()
        }
    }
    
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        
        static let name = "name"
        static let actionNodes = "actionNodes"
        static let transitionNodes = "transitionNodes"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        actionNodes = aDecoder.decodeObjectForKey(SerializationKeys.actionNodes) as! [Node]
        transitionNodes = aDecoder.decodeObjectForKey(SerializationKeys.transitionNodes) as! [Node]
        name = aDecoder.decodeObjectForKey(SerializationKeys.name) as! String
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(actionNodes, forKey: SerializationKeys.actionNodes)
        aCoder.encodeObject(transitionNodes, forKey: SerializationKeys.transitionNodes)
        aCoder.encodeObject(name, forKey: SerializationKeys.name)
    }
    
    
    // MARK: NSCopying
    
    public func copyWithZone(zone: NSZone) -> AnyObject  {
        
        let clone = Sequence()
        clone.name = name.copy() as! String
        clone.actionNodes =  NSArray(array:actionNodes, copyItems: true) as! [Node]
        clone.transitionNodes = NSArray(array:transitionNodes, copyItems: true) as! [Node]
        return clone
    }
}
