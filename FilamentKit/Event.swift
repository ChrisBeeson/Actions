//
//  Event.swift
//  Filament
//
//  Created by Chris on 20/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import EventKit
import Async
import DateTools

class Event : NSObject {
    
    var startDate: NSDate
    var endDate: NSDate
    var publish = true
    
    var period:DTTimePeriod? {
        willSet {
            guard newValue == nil else { return }
            //  updateCalendarDates(newValue!.StartDate, endDate:newValue!.EndDate)
        }
    }
    
    var owner: Node?
    var calendarEventId = ""
    var calendarEvent:EKEvent?
    
    init(period:DTTimePeriod, owner:Node) {
        
        self.startDate = period.StartDate
        self.endDate = period.EndDate
        self.owner = owner
        if owner.type == .Transition { publish = false }
        
        super.init()
        
        synchronizeCalendarEvent()
    }
    
    func synchronizeCalendarEvent() {
        
        guard publish == true else { return }
        
        guard calendarEventId.isEmpty == false  else {
            //  Async.utility { [unowned self] in
                self.createCalendarEvent()
            //}
            return
        }
        
        // Async.utility { [unowned self] in
            let store = CalendarManager.sharedInstance.store
            self.calendarEvent = store.eventWithIdentifier(self.calendarEventId)
            
            if self.calendarEvent == nil {
                self.createCalendarEvent()
            } else {
                self.updateCalendarDates(self.startDate, endDate: self.endDate)
            }
        // }
    }
    
    
    private func createCalendarEvent() {
        
        calendarEvent = EKEvent(eventStore: CalendarManager.sharedInstance.store)
        
        updateCalendarData()
        
        if let appCal = CalendarManager.sharedInstance.applicationCalendar {
            calendarEvent!.calendar = appCal
        } else {
            print("No Application Calendar")
        }
        
        saveCalendarEvent()
    }
    
    
    private func updateCalendarDates(startDate:NSDate, endDate:NSDate) {
        guard calendarEvent != nil else { return }
        
        if self.startDate.isEqualToDate(startDate) && self.endDate.isEqualToDate(endDate) {
            return
        }
        
        self.startDate = startDate
        self.endDate = endDate
        
        if publish == true {
            
            updateCalendarData()
            
            //   Async.utility { [unowned self] in
                self.saveCalendarEvent()
            // }
        }
    }
    
    func updateCalendarData() {
        guard calendarEvent != nil else { return }
        
        calendarEvent!.startDate = startDate
        calendarEvent!.endDate = endDate
        
        if let owner = self.owner {
            calendarEvent!.title = owner.title
            calendarEvent!.notes = owner.notes
        } else {
            calendarEvent!.title = "untitled"
            calendarEvent!.notes = ""
        }
    }
    
    
    private func saveCalendarEvent() {
        guard calendarEvent != nil else { return }
        do {
            try CalendarManager.sharedInstance.store.saveEvent(calendarEvent!, span: .ThisEvent, commit: true)
            self.calendarEventId = calendarEvent!.eventIdentifier
            
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        static let startDate = "startDate"
        static let endDate = "endDate"
        static let calendarEventId = "calendarEventId"
    }
    
    required init?(coder aDecoder: NSCoder) {
        startDate = aDecoder.decodeObjectForKey(SerializationKeys.startDate) as! NSDate
        endDate = aDecoder.decodeObjectForKey(SerializationKeys.endDate) as! NSDate
        calendarEventId = aDecoder.decodeObjectForKey(SerializationKeys.calendarEventId) as! String
    }
    
    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(startDate, forKey: SerializationKeys.startDate )
        encoder.encodeObject(endDate, forKey: SerializationKeys.endDate)
        encoder.encodeObject(calendarEventId, forKey: SerializationKeys.calendarEventId)
    }
}
