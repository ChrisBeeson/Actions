//
//  WaitForUserRule.swift
//  Actions
//
//  Created by Chris on 29/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import ObjectMapper


class WaitForUserRule : Rule {
    
    override var name: String { return "RULE_NAME_WAIT".localized }
    override var availableToNodeType: NodeType { return [.Action] }
    
    var userContinued = false
    
    override init() {
        super.init()
    }
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
         static let completed = "completed"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        userContinued = aDecoder.decodeBoolForKey(SerializationKeys.completed)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeBool(userContinued, forKey:SerializationKeys.completed)
    }
    
    
    // MARK: NSCopying
    
    override func copyWithZone(zone: NSZone) -> AnyObject  {
        let clone = WaitForUserRule()
        clone.userContinued = self.userContinued
        return clone
    }
    
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        userContinued <- map[SerializationKeys.completed]
    }
}