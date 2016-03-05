//
//  Calendar.swift
//  Filament
//
//  Created by Chris Beeson on 5/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class Calendar : NSObject, NSCoding {
    
    var identifier : String?
    var name : String?
    var colour : NSColor?
    var avoid = true
    

    // MARK: NSCoding
    
    private struct SerializationKeys {
        static let identifier = "identifier"
        static let name = "name"
        static let colour = "colour"
        static let avoid = "avoid"
    }
    
    required init?(coder aDecoder: NSCoder) {
        identifier = aDecoder.decodeObjectForKey(SerializationKeys.identifier) as? String
        name = aDecoder.decodeObjectForKey(SerializationKeys.name) as? String
        colour = aDecoder.decodeObjectForKey(SerializationKeys.colour) as? NSColor
        avoid  = aDecoder.decodeObjectForKey(SerializationKeys.avoid) as! Bool
        super.init()
    }
    
    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(identifier, forKey: SerializationKeys.identifier)
        encoder.encodeObject(name, forKey: SerializationKeys.name)
        encoder.encodeObject(colour, forKey: SerializationKeys.colour)
        encoder.encodeObject(avoid, forKey: SerializationKeys.avoid)
    }
}
