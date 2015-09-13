//
//  NodeInstance.swift
//  Filament
//
//  Created by Chris Beeson on 12/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation

public class NodeInstance: Node {
    
    public var startTime = NSDate()
    public var endTime = NSDate()
    public var valid:Bool = false
    
    
    public func createEventWithStartTime(startTime: NSDate) -> Bool {
        
        self.startTime = startTime
        
        valid = process()
        
        if valid {
            
            if type == .Action {
                // Create Event
                // Don't create Events For Transitions
                
                print("Created Cal Event for \(text) at \(startTime)")
            }
        }
        
        return true
    }
    
    
    public override init() {
        super.init()
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    public func duration() -> NSDate {
    
    }
    */
    
    
    private func process() -> Bool {
        
        for rule in rules {
            
            let operation = rule.runRule(startTime, nextRuleToSatisfy: rule, calendersToAvoid:nil)
            
            if operation.valid == false {return false}
            
            endTime = operation.endDate!
        }
        
        return true
    }
}
