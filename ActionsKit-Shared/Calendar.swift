//
//  Calendar.swift
//  Actions
//
//  Created by Chris Beeson on 5/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import EventKit
import ObjectMapper

open class Calendar : NSObject, NSCoding, Mappable {
    
    var identifier : String?
    var name : String?
    var colour : NSColor?
    var avoid = true
    
    public convenience init(systemCalendar:EKCalendar) {
        self.init()
        self.identifier = systemCalendar.calendarIdentifier
        self.name = systemCalendar.title
        self.colour = systemCalendar.color
    }
    
    override init() {
        super.init()
    }
    

    // MARK: NSCoding
    
    fileprivate struct SerializationKeys {
        static let identifier = "identifier"
        static let name = "name"
        static let colour = "colour"
        static let avoid = "avoid"
    }
    
    required public init?(coder aDecoder: NSCoder) {
        identifier = aDecoder.decodeObject(forKey: SerializationKeys.identifier) as? String
        name = aDecoder.decodeObject(forKey: SerializationKeys.name) as? String
        colour = aDecoder.decodeObject(forKey: SerializationKeys.colour) as? NSColor
        avoid  = aDecoder.decodeObject(forKey: SerializationKeys.avoid) as! Bool
        super.init()
    }
    
    open func encode(with encoder: NSCoder) {
        encoder.encode(identifier, forKey: SerializationKeys.identifier)
        encoder.encode(name, forKey: SerializationKeys.name)
        encoder.encode(colour, forKey: SerializationKeys.colour)
        encoder.encode(avoid, forKey: SerializationKeys.avoid)
    }
    
    //MARK: Mapping
    
    required public init?(_ map: Map) {
        
    }
    
    open func mapping(_ map: Map) {
        identifier              <- map[SerializationKeys.identifier]
        name                    <- map[SerializationKeys.name]
        // colour                  <- map[SerializationKeys.colour]
        //TODO: Transform Colour
        avoid                   <- map[SerializationKeys.avoid]

    }
    
    // MARK: Equality
    
    override  open func isEqual(_ object: Any?) -> Bool {
        
        if let cal = object as? Calendar {
            //   if self.name == cal.name && self.colour!.isEqual(cal.colour) {
            if self.name == cal.name {
                return true
            }
            return false
        }
        return false
    }
}
