//
//  CalendarEvent.swift
//  Actions
//
//  Created by Chris on 20/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import EventKit
import DateTools
import ObjectMapper

class CalendarEvent : NSObject, NSCoding, NSCopying, Mappable {
    
    var startDate: NSDate
    var endDate: NSDate
    var publish = false
    weak var owner: Node?
    var eventId = ""
    var systemEvent:EKEvent?
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
        
        if eventId.isEmpty == true {
            createCalendarEvent()
            processing = false
            return
        }
        
        self.systemEvent = findSystemEvent()
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
            if self.systemEvent == nil {
                self.createCalendarEvent()
            } else {
                self.updateSystemCalendarData()
            }
        })
    }
    
    private func findSystemEvent() -> EKEvent? {
        let store = CalendarManager.sharedInstance.store
        let items = store.calendarItemsWithExternalIdentifier(eventId)
        if items.count > 0 { return items[0] as? EKEvent }
        return nil
        // TODO: Look through events with predicate to match them with name and dates.
    }
    
    
    private func createCalendarEvent() {
        guard CalendarManager.sharedInstance.authorized == true else { return }
        
        // first lets make sure that an event with same dates and title doesn't already Exist.
        
        let events = CalendarManager.sharedInstance.findEventsInApplicationCalendar(DTTimePeriod(startDate: self.startDate, endDate: self.endDate))
        
        if events != nil && events!.count>0 {
            self.systemEvent = events![0]
        } else  {
            CalendarManager.sharedInstance.incrementChangeCount()
            systemEvent = EKEvent(eventStore: CalendarManager.sharedInstance.store)
            if let appCal = CalendarManager.sharedInstance.applicationCalendar {
                systemEvent!.calendar = appCal
            } else {
                print("No Application Calendar")
            }
        }
        updateSystemCalendarData()
    }
    
    
    func updateSystemCalendarData() {
        guard CalendarManager.sharedInstance.authorized == true else { return }
        guard systemEvent != nil else { return }
        guard publish == true else { return }
        
        var dirty = false
        if systemEvent!.startDate != startDate { systemEvent!.startDate = startDate ; dirty = true }
        if systemEvent!.endDate != endDate { systemEvent!.endDate = endDate ; dirty = true }
        
        if let owner = self.owner {
            if systemEvent!.title != owner.title { systemEvent!.title = owner.title ; dirty = true }
            if systemEvent!.notes != owner.notes { systemEvent!.notes = owner.notes ; dirty = true }
            if systemEvent!.location != owner.location { systemEvent!.location = owner.location ; dirty = true }
        }
        
        // Alarms
        dirty = synchronizeAlarms() == true ? true : dirty
        
        if dirty == true { self.saveCalendarEvent() }
        processing = false
    }
    
    
    func synchronizeAlarms() -> Bool {
        guard let node = owner else { return false }
        
        systemEvent?.alarms?.removeAll()
        
        for rule in node.rules { if rule.className == EventAlarmRule.className() {
            if let newAlarm = (rule as! EventAlarmRule).makeAlarm() {
                systemEvent?.addAlarm(newAlarm)
            }
            }
        }
        return true
    }
    
    
    private func saveCalendarEvent() {
        guard CalendarManager.sharedInstance.authorized == true else { return }
        guard systemEvent != nil else { return }
        
        do {
            CalendarManager.sharedInstance.incrementChangeCount()
            try CalendarManager.sharedInstance.store.saveEvent(systemEvent!, span: .ThisEvent, commit: true)
            self.eventId = systemEvent!.calendarItemExternalIdentifier
            
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    
    func deleteCalenderEvent() {
        guard CalendarManager.sharedInstance.authorized == true else { return }
        if systemEvent == nil { systemEvent = findSystemEvent() }
        guard systemEvent != nil else { return }
        
        do {
            CalendarManager.sharedInstance.incrementChangeCount()
            try CalendarManager.sharedInstance.store.removeEvent(systemEvent!, span: .ThisEvent, commit: true)
            self.eventId = ""
            self.systemEvent = nil
            
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func forceNodeToMatchSystemCalendarEvent() {
        
        guard let newSystemEvent = findSystemEvent() else { return }
        
        
        if startDate.isEqualToDate(newSystemEvent.startDate) == false || endDate.isEqualToDate(newSystemEvent.endDate) == false {
            print("System Calendar has changed dates for Event")
            
        }
        
        // Find system calendar event
        // Does it match the time we expect
        // if not add a startTime rule.
        
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
        self.startDate = map[SerializationKeys.startDate].valueOr(NSDate.distantPast())
        self.endDate = map[SerializationKeys.endDate].valueOr(NSDate.distantFuture())
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
