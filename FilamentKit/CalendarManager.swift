//
//  CalendarManager.swift
//  Filament
//
//  Created by Chris Beeson on 12/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import EventKit
import DateTools

public class CalendarManager: NSObject {
    
    static let sharedInstance = CalendarManager()
    
    private let store = EKEventStore()
    
    
    func calendars() -> [EKCalendar] {
        
        return store.calendarsForEntityType(.Event)
    }
    
    
    func events(timePeriod: DTTimePeriod, calendars: [EKCalendar]) -> [EKEvent]? {
        
        let predicate = store.predicateForEventsWithStartDate(timePeriod.StartDate, endDate: timePeriod.EndDate, calendars: calendars)
        
        return store.eventsMatchingPredicate(predicate)
    }
    
    
    func publishEvent(event:EKEvent) {
        
        do {
            
        try store.saveEvent(event, span: .ThisEvent, commit: true)
            
        } catch let error as NSError {
        
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
    }
}