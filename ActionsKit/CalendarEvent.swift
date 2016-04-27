//
//  CalendarEvent.swift
//  Actions
//
//  Created by Chris on 20/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import EventKit
import Async
import DateTools
import ObjectMapper

class CalendarEvent : NSObject, NSCoding, NSCopying, Mappable {
    
    var startDate: NSDate
    var endDate: NSDate
    var publish = false
    weak var owner: Node?
    var eventId = ""
    var event:EKEvent?
    private var processing = false
    
    var period:DTTimePeriod? {
        willSet {
            guard newValue != nil else { return }
            guard processing != true else { return }
            processing = true
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
        
        if eventId.isEmpty == true{
            self.createCalendarEvent()
            processing = false
            return
        }
        
        Async.userInitiated() {
            let store = CalendarManager.sharedInstance.store
            let items = store.calendarItemsWithExternalIdentifier(self.eventId)
            if items.count > 0 {
                self.event = items[0] as? EKEvent
            }
            
            if self.event == nil {
                self.createCalendarEvent()
            } else {
                self.updateSystemCalendarData()
            }
        }
    }
    
    
    private func createCalendarEvent() {
        guard CalendarManager.sharedInstance.authorized == true else { return }
        
        // first lets make sure that an event with same dates and title doesn't already Exist.
        
        let events = CalendarManager.sharedInstance.findEventsInApplicationCalendar(DTTimePeriod(startDate: self.startDate, endDate: self.endDate))
        
        if events != nil && events!.count>0 {
            self.event = events![0]
        } else  {
            // make a new Event
            CalendarManager.sharedInstance.incrementChangeCount()
            event = EKEvent(eventStore: CalendarManager.sharedInstance.store)
            //print("Creating new event for owner \(owner)")
            
            if let appCal = CalendarManager.sharedInstance.applicationCalendar {
                event!.calendar = appCal
            } else {
                print("No Application Calendar")
            }
        }
        updateSystemCalendarData()
    }
    
    
    func updateSystemCalendarData() {
        guard CalendarManager.sharedInstance.authorized == true else { return }
        guard event != nil else { return }
        guard publish == true else { return }
        
        var dirty = false
        if event!.startDate != startDate { event!.startDate = startDate ; dirty = true }
        if event!.endDate != endDate { event!.endDate = endDate ; dirty = true }
        
        if let owner = self.owner {
            if event!.title != owner.title { event!.title = owner.title ; dirty = true }
            if event!.notes != owner.notes { event!.notes = owner.notes ; dirty = true }
            if event!.location != owner.location { event!.location = owner.location ; dirty = true }
        }
        
        // Alarms
        dirty = synchronizeAlarms() == true ? true : dirty
        
        if dirty == true { self.saveCalendarEvent() }
        processing = false
    }
    
    
    func synchronizeAlarms() -> Bool {
        guard let node = owner else { return false }
        
        event?.alarms?.removeAll()
        
        for rule in node.rules { if rule.className == EventAlarmRule.className() {
            
            if let newAlarm = (rule as! EventAlarmRule).makeAlarm() {
                event?.addAlarm(newAlarm)
                Swift.print("Alarm added To event")
            }
            }
        }
        return true
    }
    
    
    private func saveCalendarEvent() {
        guard CalendarManager.sharedInstance.authorized == true else { return }
        guard event != nil else { return }
        print("Saving Event \(event?.title)")
        
        do {
            CalendarManager.sharedInstance.incrementChangeCount()
            try CalendarManager.sharedInstance.store.saveEvent(event!, span: .ThisEvent, commit: true)
            self.eventId = event!.calendarItemExternalIdentifier
            
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    
    func deleteCalenderEvent() {
        guard CalendarManager.sharedInstance.authorized == true else { return }
        guard event != nil else { return }
        print("Deleting Event \(event?.title)")
        
        do {
            CalendarManager.sharedInstance.incrementChangeCount()
            try CalendarManager.sharedInstance.store.removeEvent(event!, span: .ThisEvent, commit: true)
            self.eventId = ""
            self.event = nil
            
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        static let startDate = "startDate"
        static let endDate = "endDate"
        static let eventId = "eventId"
        static let publish = "publish"
    }
    
    required init?(coder aDecoder: NSCoder) {
        startDate = aDecoder.decodeObjectForKey(SerializationKeys.startDate) as! NSDate
        endDate = aDecoder.decodeObjectForKey(SerializationKeys.endDate) as! NSDate
        eventId = aDecoder.decodeObjectForKey(SerializationKeys.eventId) as! String
        publish = aDecoder.decodeObjectForKey(SerializationKeys.publish) as! Bool
    }
    
    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(startDate, forKey: SerializationKeys.startDate )
        encoder.encodeObject(endDate, forKey: SerializationKeys.endDate)
        encoder.encodeObject(eventId, forKey: SerializationKeys.eventId)
        encoder.encodeObject(publish, forKey: SerializationKeys.publish)
    }
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        self.startDate = map[SerializationKeys.startDate].value()!
        self.endDate = map[SerializationKeys.endDate].value()!
        
    }
    
    func mapping(map: Map) {
        startDate           <- (map[SerializationKeys.startDate], DateTransform())
        endDate             <- (map[SerializationKeys.endDate], DateTransform())
        eventId             <- map[SerializationKeys.eventId]
        publish             <- map[SerializationKeys.publish]
    }
    
    
    // MARK: NSCopying
    
    func copyWithZone(zone: NSZone) -> AnyObject  {
        
        let clone = CalendarEvent()
        clone.startDate = self.startDate.copy() as! NSDate
        clone.endDate = self.endDate.copy() as! NSDate
        clone.publish = self.publish
        clone.eventId = self.eventId.copy() as! String
        return clone
    }
}
