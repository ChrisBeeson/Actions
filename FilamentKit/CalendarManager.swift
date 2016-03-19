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
    
    public static let sharedInstance = CalendarManager()
    public let store = EKEventStore()
    public var applicationCalendar: EKCalendar?
    public var authorized = false
    var changeCount = 0
    
    override init() {
        
        super.init()
        verifyUserEventAuthorization()
        retrieveApplicationCalendar()
        
        NSNotificationCenter.defaultCenter().addObserverForName(EKEventStoreChangedNotification, object: nil, queue: nil) { (notification) -> Void in
            if self.changeCount > 0 { self.changeCount-- } else {
                NSNotificationCenter.defaultCenter().postNotificationName("UpdateAllSequences", object: self)
            }
        }
    }
    
    deinit {
       NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func calendars() -> [EKCalendar] {
        
        return store.calendarsForEntityType(.Event)
    }
    
    func incrementChangeCount() {
        changeCount++
    }
    
    func events(timePeriod: DTTimePeriod, calendars: [Calendar]) -> [EKEvent]? {

        let systemCalendars = systemCalendarsForCalendars(calendars)
        
        let predicate = store.predicateForEventsWithStartDate(timePeriod.StartDate, endDate: timePeriod.EndDate, calendars: systemCalendars)
        return store.eventsMatchingPredicate(predicate)
    }
    
    
    func findEventsInApplicationCalendar(timePeriod: DTTimePeriod) -> [EKEvent]? {
        guard applicationCalendar != nil else { print("Application Calendar is NULL") ; return nil }
        
        let predicate = store.predicateForEventsWithStartDate(timePeriod.StartDate, endDate: timePeriod.EndDate, calendars: [applicationCalendar!])
        return store.eventsMatchingPredicate(predicate)
    }
    
    
    
    
    func systemCalendarsForCalendars(calendars: [Calendar]) -> [EKCalendar] {
    
        var systemCalendars = [EKCalendar]()
        
        for cal in calendars {
            if let id = cal.identifier {
                if let cal = store.calendarWithIdentifier(id) {
                    systemCalendars.append(cal)
                }
            }
        }
        return systemCalendars
    }
    
    func systemCalendarsAsCalendars() -> [Calendar] {

        return store.calendarsForEntityType(EKEntityType.Event).map{ Calendar(systemCalendar:$0) }
    }
    

    func retrieveApplicationCalendar() {
        
        if applicationCalendar == nil {
            let calendars = store.calendarsForEntityType(EKEntityType.Event)
            for calendar in calendars {
                if calendar.title ==  AppConfiguration.defaultFilamentCalendarName as String {
                    applicationCalendar = calendar
                    break
                }
            }
            
            if applicationCalendar == nil {
                applicationCalendar = EKCalendar(forEntityType: EKEntityType.Event, eventStore:store)
                applicationCalendar!.title = AppConfiguration.defaultFilamentCalendarName as String
                applicationCalendar!.source = store.defaultCalendarForNewEvents.source
                
                do {
                    try store.saveCalendar(applicationCalendar!, commit: true)
                }
                catch let error as NSError {
                    print("retrieveApplicationCalendar() Unresolved error \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    
    public func verifyUserEventAuthorization() {
        
        switch EKEventStore.authorizationStatusForEntityType(EKEntityType.Event) {
            
        case .NotDetermined:
            store.requestAccessToEntityType(.Event, completion: { granted, error in
                switch granted {
                case true: print("Granted Access to calendar")
                case false: print("NOT Granted Access to calendar") ; self.handleUnauthorizedCalendar()
                }
            })
        case .Authorized: print("Access to calendar is Authorized")
        authorized = true
        store.requestAccessToEntityType(.Event, completion: { (success, error) -> Void in
        })
            
        case .Denied: print("Access to calendar is denied") ; handleUnauthorizedCalendar()
        case .Restricted: print("Access to calendar is Restricted"); handleUnauthorizedCalendar()
        }
    }
    
    func handleUnauthorizedCalendar() {
        NSNotificationCenter.defaultCenter().postNotificationName("DisplayCannotAccessCalendarAlert",object: nil)
    }
}