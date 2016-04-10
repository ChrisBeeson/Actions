//
//  WaitForUserRule.swift
//  Filament
//
//  Created by Chris on 29/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import ObjectMapper


class WaitForUserRule : Rule {
    
    override var name: String { return "RULE_NAME_WAIT".localized }
    override var availableToNodeType: NodeType { return [.Action] }
    
    override init() {
        super.init()
    }
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        // static let duration = "duration"
        //   static let minDuration = "minDuration"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        //   calendars = aDecoder.decodeObjectForKey("calendars") as! [EKCalendar]
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        //aCoder.encodeObject(calendars, forKey:"calendars")
    }
    
    
    // MARK: NSCopying
    
    override func copyWithZone(zone: NSZone) -> AnyObject  {  //TODO: NSCopy
        /*
         let clone = Sequence()
         clone.title = title.copy() as! String
         return clone
         */
        return self
    }
    
    
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
    }
}