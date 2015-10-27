//
//  Instance.swift
//  Filament
//
//  Created by Chris on 14/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import EventKit

public class Instance: NSObject {
    
    public var startDate = NSDate()
    public var text = ""
    public var sequence = Sequence()
    public var calendarsToAvoid = [EKCalendar]()
    
    private var events = [Event]()
    
    public init(startDate: NSDate, sequence: Sequence) {
        
        self.startDate = startDate
        self.sequence = sequence
        super.init()
        
        update()
    }
    
    public func update() {
        
        precondition(sequence.validSequence(), "Trying to process an instance of a sequence that is not valid")
        
        // 1. make sure events[] == sequence array.
        
        validateEvents()
        
        
        
        
        
      //  let result = Solver().solveEvents(events, startDate:self.startDate, avoidCalendars:nil)
        
       // print(result)
        
        
     /*
        
        for (index, node) in sequence.allNodes().enumerate() {
            
            
        }
        
       
        
            // create event if it doesn't exist
            
            if events[index] == nil {
                
                events[index] = Event(node:node)
                
            } else {
                
                if events[index]!.node == sequence.allNodes()[index] {
                    
                    events[index]!.startDate = startDate
                    
                } else {
                    
                    events[index] = nil
                    events[index] = Event(node:node)
                }
            }
        }

*/
        
        // TODO: if sequence has had nodes removed need to remove them from our events list.
        
        
        
    }
    
    
    internal func validateEvents() {
        
        if events.count == 0 { populateEventsFromSequenceNodes(0); return; }
        
    }
    
    internal func populateEventsFromSequenceNodes(startingNodeIndex: Int) {
        
        //delete all Events from starting Node index
        
       for var index = startingNodeIndex ; index < sequence.allNodes().count-1 ; ++index {
        }
        // a
        
    }
}

