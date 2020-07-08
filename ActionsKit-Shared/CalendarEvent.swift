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
    
    var startDate: Date
    var endDate: Date
    var publish = false
    weak var owner: Node?
    var eventId = ""
    var systemEvent:EKEvent?
    fileprivate var processing = false
    
    var period:DTTimePeriod? {
        willSet {
            guard newValue != nil else { return }
            guard processing != true else { return }
            processing = true
            self.startDate = newValue!.startDate
            self.endDate = newValue!.endDate
            synchronizeCalendarEvent()
        }
    }
    
    func timePeriod() -> DTTimePeriod {
        return DTTimePeriod(start: startDate, end: endDate)
    }
    
    override init() {
        startDate = Date.distantPast
        endDate = Date.distantFuture
        super.init()
    }
    
    
    init(period:DTTimePeriod, owner:Node) {
        self.startDate = period.startDate
        self.endDate = period.endDate
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
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
            if self.systemEvent == nil {
                self.createCalendarEvent()
            } else {
                self.updateSystemCalendarData()
            }
        })
    }
    
    fileprivate func findSystemEvent() -> EKEvent? {
        let store = CalendarManager.sharedInstance.store
        let items = store.calendarItems(withExternalIdentifier: eventId)
        if items.count > 0 { return items[0] as? EKEvent }
        return nil
        // TODO: Look through events with predicate to match them with name and dates.
    }
    
    
    fileprivate func createCalendarEvent() {
        guard CalendarManager.sharedInstance.authorized == true else { return }
        
        // first lets make sure that an event with same dates and title doesn't already Exist.
        
        let events = CalendarManager.sharedInstance.findEventsInApplicationCalendar(DTTimePeriod(start: self.startDate, end: self.endDate))
        
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
    
    
    fileprivate func saveCalendarEvent() {
        guard CalendarManager.sharedInstance.authorized == true else { return }
        guard systemEvent != nil else { return }
        
        do {
            CalendarManager.sharedInstance.incrementChangeCount()
            try CalendarManager.sharedInstance.store.save(systemEvent!, span: .thisEvent, commit: true)
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
            try CalendarManager.sharedInstance.store.remove(systemEvent!, span: .thisEvent, commit: true)
            self.eventId = ""
            self.systemEvent = nil
            
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func forceNodeToMatchSystemCalendarEvent() {
        guard let newSystemEvent = findSystemEvent() else { return }
        if (startDate == newSystemEvent.startDate) == true && (endDate == newSystemEvent.endDate) == true { return }
        print("System Calendar has changed dates for Event \(owner!.title)")
        
        
        
        let fixedRule:EventFixedStartAndEndDate
        
        /*
        
        if let fR = owner?.rules.filter { $0 is EventFixedStartAndEndDate }
        
        fixedRule.startDate = newSystemEvent.startDate
        fixedRule.endDate = newSystemEvent.endDate
        owner?.rules.append(fixedRule)
        startDate = newSystemEvent.startDate
        endDate = newSystemEvent.endDate
 */
    }
    
    
    
    // MARK: NSCoding
    
    fileprivate struct SerializationKeys {
        static let startDate = "startDate"
        static let endDate = "endDate"
        static let eventId = "eventId"
        static let publish = "publish"
    }
    
    required init?(coder aDecoder: NSCoder) {
        startDate = aDecoder.decodeObject(forKey: SerializationKeys.startDate) as! Date
        endDate = aDecoder.decodeObject(forKey: SerializationKeys.endDate) as! Date
        eventId = aDecoder.decodeObject(forKey: SerializationKeys.eventId) as! String
        publish = aDecoder.decodeObject(forKey: SerializationKeys.publish) as! Bool
    }
    
    func encode(with encoder: NSCoder) {
        encoder.encode(startDate, forKey: SerializationKeys.startDate )
        encoder.encode(endDate, forKey: SerializationKeys.endDate)
        encoder.encode(eventId, forKey: SerializationKeys.eventId)
        encoder.encode(publish, forKey: SerializationKeys.publish)
    }
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        self.startDate = map[SerializationKeys.startDate].valueOr(NSDate.distantPast())
        self.endDate = map[SerializationKeys.endDate].valueOr(NSDate.distantFuture())
    }
    
    func mapping(_ map: Map) {
        startDate           <- (map[SerializationKeys.startDate], DateTransform())
        endDate             <- (map[SerializationKeys.endDate], DateTransform())
        eventId             <- map[SerializationKeys.eventId]
        publish             <- map[SerializationKeys.publish]
    }
    
    
    // MARK: NSCopying
    
    func copy(with zone: NSZone?) -> Any  {
        let clone = CalendarEvent()
        clone.startDate = self.startDate.copy() as! NSDate
        clone.endDate = self.endDate.copy() as! NSDate
        clone.publish = self.publish
        clone.eventId = self.eventId.copy() as! String
        return clone
    }
}
