//
//  TimeEvent.swift
//  Filament
//
//  Created by Chris on 20/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import EventKit
import Async
import DateTools

class TimeEvent : NSObject, NSCoding, NSCopying {
    
    var startDate: NSDate
    var endDate: NSDate
    var publish = false
    var owner: Node?
    var calendarEventId = ""
    var calendarEvent:EKEvent?
    
    var period:DTTimePeriod? {
        
        willSet {
            guard newValue != nil else { return }
            self.startDate = newValue!.StartDate
            self.endDate = newValue!.EndDate
            synchronizeCalendarEvent()
        }
    }
    
    
    func timePeriod() -> DTTimePeriod {
        return DTTimePeriod(startDate: startDate, endDate: endDate)
    }
    
    override init() {
        startDate = NSDate.distantPast()
        endDate = NSDate.distantFuture()
        super.init()
    }

    
    init(period:DTTimePeriod, owner:Node) {
        
        self.startDate = period.StartDate
        self.endDate = period.EndDate
        self.owner = owner
       
        super.init()
         if owner.type == .Action { publish = true}
        
        synchronizeCalendarEvent()
    }
    
    func synchronizeCalendarEvent() {
        
        guard publish == true else { return }
        guard CalendarManager.sharedInstance.authorized == true else { return }
        
        if calendarEventId.isEmpty == true{
            self.createCalendarEvent()
            return
        }
        
        // Async.utility { [unowned self] in
        
        let store = CalendarManager.sharedInstance.store
        let items = store.calendarItemsWithExternalIdentifier(self.calendarEventId)
        if items.count > 0 {
            self.calendarEvent = items[0] as? EKEvent
        }
        
        if self.calendarEvent == nil {
            self.createCalendarEvent()
        } else {
            updateSystemCalendarData()
        }
        // }
    }
    
    
    private func createCalendarEvent() {
         guard CalendarManager.sharedInstance.authorized == true else { return }
        
        // first lets make sure that an event with same dates and title doesn't already Exist.
        
        let events = CalendarManager.sharedInstance.findEventsInApplicationCalendar(DTTimePeriod(startDate: self.startDate, endDate: self.endDate))
        
        if events != nil && events!.count>0 {
            self.calendarEvent = events![0]
        } else  {
            // make a new Event
            calendarEvent = EKEvent(eventStore: CalendarManager.sharedInstance.store)
            print("Creating new event")
            
            if let appCal = CalendarManager.sharedInstance.applicationCalendar {
                calendarEvent!.calendar = appCal
            } else {
                print("No Application Calendar")
            }
        }
        
        updateSystemCalendarData()
    }
    
    
    func updateSystemCalendarData() {
        guard CalendarManager.sharedInstance.authorized == true else { return }
        guard calendarEvent != nil else { return }
        guard publish == true else { return }
        
        var dirty = false
        if calendarEvent!.startDate != startDate { calendarEvent!.startDate = startDate ; dirty = true }
        if calendarEvent!.endDate != endDate { calendarEvent!.endDate = endDate ; dirty = true }
        
        if let owner = self.owner {
            if calendarEvent!.title != owner.title { calendarEvent!.title = owner.title ; dirty = true }
            if calendarEvent!.notes != owner.notes { calendarEvent!.notes = owner.notes ; dirty = true }
            if calendarEvent!.location != owner.location { calendarEvent!.location = owner.location ; dirty = true }
        }
        
        if dirty == true {
            //   Async.background { [unowned self] in
                self.saveCalendarEvent()
            //     }
        }
    }
    
    
    private func saveCalendarEvent() {
        guard CalendarManager.sharedInstance.authorized == true else { return }
        guard calendarEvent != nil else { return }
        
        do {
            CalendarManager.sharedInstance.incrementChangeCount()
            try CalendarManager.sharedInstance.store.saveEvent(calendarEvent!, span: .ThisEvent, commit: true)
            self.calendarEventId = calendarEvent!.calendarItemExternalIdentifier
            
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    
    func deleteCalenderEvent() {
        guard CalendarManager.sharedInstance.authorized == true else { return }
        guard calendarEvent != nil else { return }
        
        do {
            CalendarManager.sharedInstance.incrementChangeCount()
            try CalendarManager.sharedInstance.store.removeEvent(calendarEvent!, span: .ThisEvent, commit: true)
            self.calendarEventId = ""
            self.calendarEvent = nil
            
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        static let startDate = "startDate"
        static let endDate = "endDate"
        static let calendarEventId = "calendarEventId"
        static let publish = "publish"
    }
    
    required init?(coder aDecoder: NSCoder) {
        startDate = aDecoder.decodeObjectForKey(SerializationKeys.startDate) as! NSDate
        endDate = aDecoder.decodeObjectForKey(SerializationKeys.endDate) as! NSDate
        calendarEventId = aDecoder.decodeObjectForKey(SerializationKeys.calendarEventId) as! String
        publish = aDecoder.decodeObjectForKey(SerializationKeys.publish) as! Bool
    }
    
    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(startDate, forKey: SerializationKeys.startDate )
        encoder.encodeObject(endDate, forKey: SerializationKeys.endDate)
        encoder.encodeObject(calendarEventId, forKey: SerializationKeys.calendarEventId)
        encoder.encodeObject(publish, forKey: SerializationKeys.publish)
    }
    
    // MARK: NSCopying
    
    func copyWithZone(zone: NSZone) -> AnyObject  {

        let clone = TimeEvent()
        clone.startDate = self.startDate.copy() as! NSDate
        clone.endDate = self.endDate.copy() as! NSDate
        clone.publish = self.publish
        clone.calendarEventId = self.calendarEventId.copy() as! String
        return clone
    }
}
