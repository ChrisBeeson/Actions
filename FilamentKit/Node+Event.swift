//
//  Node+Event.swift
//  Filament
//
//  Created by Chris Beeson on 15/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import EventKit
import DateTools

extension Node {
    
    var event:EKEvent? {
        
        if self.eventID.isEmpty {return nil}
        let store = CalendarManager.sharedInstance.store
        return store.eventWithIdentifier(self.eventID)
    }
    
     func updateCalendarEventWithTimePeriod(period:DTTimePeriod) {
        
        // Already have a correct event?
        
        if self.event != nil && self.event!.startDate.isEqualToDate(period.StartDate) == true && self.event?.endDate.isEqualToDate(period.EndDate) == true {
            return
        }
        
        let store = CalendarManager.sharedInstance.store
        
        // Node has an Event, but it's wrong so lets delete it.
        // TODO: rather than delete out of Date events, move them.
        
        if self.event != nil {
            do {
                try store.removeEvent(self.event!, span: .ThisEvent, commit: true)
                
            } catch let error as NSError {
                print("Unresolved error deleting Event \(error), \(error.userInfo)")
            }
            //   self.event = nil
            self.eventID = ""
        }
        
        // Create Event
        
        let event = EKEvent(eventStore: store)
        event.title = self.title
        event.startDate = period.StartDate
        event.endDate = period.EndDate
        
        if let appCal = CalendarManager.sharedInstance.applicationCalendar {
            
            event.calendar = appCal
        } else {
            print("No Application Calendar")
        }
        
        do {
            try store.saveEvent(event, span: .ThisEvent, commit: true)
            //  self.event = event
            self.eventID = event.eventIdentifier
            
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
    }
}