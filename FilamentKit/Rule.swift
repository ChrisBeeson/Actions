//
//  Rule.swift
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2015 Andris Ltd. All rights reserved.
//

import Foundation

public protocol RuleType {
    
    var name: String { get }
    
    // var availableToNodeType:Node.Type { get }
    
    var conflictingRules: [Rule]? { get }
    
    func runRule(startDate: NSDate, nextRuleToSatisfy: Rule, calendersToAvoid:[AnyObject]?) -> (valid:Bool, endDate:NSDate?)
    
}

public class Rule : NSObject, RuleType {
    
    public var name: String { return "Abstract Rule" }
    public var availableToNodeType: Node.NodeType { return .All  }
    public var conflictingRules: [Rule]? { return nil }
    
    public func runRule(startDate: NSDate, nextRuleToSatisfy: Rule, calendersToAvoid:[AnyObject]?) -> (valid:Bool, endDate:NSDate?) {
        
        return (false,nil)
    }
    
    
     // MARK: NSCoding
    
    // MARK: NSCopying
    

    
    
}