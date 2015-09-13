//
//  CalendarManager.swift
//  Filament
//
//  Created by Chris Beeson on 12/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import EventKit

public class CalendarManager: NSObject {
    
    static let sharedInstance = CalendarManager()
    
    private static let store = EKEventStore()
    
    override init() {
        
    }
    
}