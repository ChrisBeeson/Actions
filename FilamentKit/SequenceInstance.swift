//
//  SequenceInstance.swift
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2015 Andris Ltd. All rights reserved.
//

import Foundation

public class SequenceInstance: Sequence {
    
    
    // Instances are just a start date, and a group of cal events to each action event...
    
    
    
    // Instances handle the rules & calendar Events
    
    //   public var startDate: NSDate
    //private var calendarEvents = [AnyObject]()
    
    private var nodeInstances = [NodeInstance]()
    
    public var startDate = NSDate()
    
    public init (startDate: NSDate) {
        
        super.init()
        
        self.startDate = startDate
        process()
    }
    
    override init() {
        
        super.init()
    }

    
    public required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    public func process() {
        
        // TODO: Notice changes and update, not delete and restart!
        
        for node in nodeInstances {
            nodeInstances.removeObject(node)
        }
        
        
        var currentTime = startDate
        
        let nodes = allNodes()
        
        for var index = 0 ; index < nodes.count - 1 ; ++index {
            
            let nodeInstance = nodes[index].instance("instance")
            
            nodeInstances.append(nodeInstance)
            
            if (nodeInstance.createEventWithStartTime(currentTime)) {
                
                currentTime = nodeInstance.endTime
                
            }else {
                
                print("Could not meet rule requirements")
                
                break
            }
            
        }
    }
}