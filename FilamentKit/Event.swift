//
//  Event.swift
//  Filament
//
//  Created by Chris on 15/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import EventKit

public class Event: NSObject {
    
    public var node: Node
    
    private var caledarEvent: EKEvent?
    
    public var startDate: NSDate? {
        
        didSet { if oldValue != startDate { update() } }
    }
    
    public var endDate: NSDate?
    
    public init(node: Node) {
        
        self.node = node
    }
    
    public func update() {
        
    }
}
