//
//  CalendarManager.swift
//  Actions
//
//  Created by Chris Beeson on 12/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import EventKit
import DateTools

open class CalendarManager: NSObject {
    
    open static let sharedInstance = CalendarManager()
    open let store = EKEventStore()
    open var applicationCalendar: EKCalendar?
    open var authorized = false
    var changeCount = 0
    
    override init() {
        super.init()
        verifyUserEventAuthorization()
        retrieveApplicationCalendar()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.EKEventStoreChanged, object: nil, queue: nil) { (notification) -> Void in
            if self.changeCount > 0 {
                self.changeCount -= 1
            } else {
                 print("Calendar Changed Outside of Actions")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "SystemCalendarDidChangeExternally"), object: self)
            }
        }
    }
    
    deinit {
       NotificationCenter.default.removeObserver(self)
    }
    
    func calendars() -> [EKCalendar] {
        return store.calendars(for: .event)
    }
    
    func incrementChangeCount() {
        changeCount += 1
    }
    
    func events(_ timePeriod: DTTimePeriod, calendars: [Calendar]) -> [EKEvent]? {

        let systemCalendars = systemCalendarsForCalendars(calendars)
        
        let predicate = store.predicateForEvents(withStart: timePeriod.startDate, end: timePeriod.endDate, calendars: systemCalendars)
        return store.events(matching: predicate)
    }
    
    
    func findEventsInApplicationCalendar(_ timePeriod: DTTimePeriod) -> [EKEvent]? {
        guard applicationCalendar != nil else { print("Application Calendar is NULL") ; return nil }
        
        let predicate = store.predicateForEvents(withStart: timePeriod.startDate, end: timePeriod.endDate, calendars: [applicationCalendar!])
        return store.events(matching: predicate)
    }
    
    
    
    
    func systemCalendarsForCalendars(_ calendars: [Calendar]) -> [EKCalendar] {
        var systemCalendars = [EKCalendar]()
        for cal in calendars {
            if let id = cal.identifier {
                if let cal = store.calendar(withIdentifier: id) {
                    systemCalendars.append(cal)
                }
            }
        }
        return systemCalendars
    }
    
    func systemCalendarsAsCalendars() -> [Calendar] {
        return store.calendars(for: EKEntityType.event).map{ Calendar(systemCalendar:$0) }
    }
    

    func retrieveApplicationCalendar() {
        if applicationCalendar == nil {
            let calendars = store.calendars(for: EKEntityType.event)
            for calendar in calendars {
                if calendar.title ==  AppConfiguration.defaultCalendarName as String {
                    applicationCalendar = calendar
                    break
                }
            }
            
            if applicationCalendar == nil {
                applicationCalendar = EKCalendar(for: EKEntityType.event, eventStore:store)
                applicationCalendar!.title = AppConfiguration.defaultCalendarName as String
                applicationCalendar!.color = AppConfiguration.defaultCalendarColour as NSColor
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
    
    
    open func verifyUserEventAuthorization() {
        switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
            
        case .notDetermined:
            store.requestAccess(to: .event, completion: { granted, error in
                switch granted {
                case true: print("Granted Access to calendar")
                case false: print("NOT Granted Access to calendar") ; self.handleUnauthorizedCalendar()
                }
            })
        case .authorized: print("Access to calendar is Authorized")
        authorized = true
        store.requestAccess(to: .event, completion: { (success, error) -> Void in
        })
            
        case .denied: print("Access to calendar is denied") ; handleUnauthorizedCalendar()
        case .restricted: print("Access to calendar is Restricted"); handleUnauthorizedCalendar()
        }
    }
    
    func handleUnauthorizedCalendar() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "DisplayCannotAccessCalendarAlert"),object: nil)
    }
}
