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
    public let store = EKEventStore()
    public var applicationCalendar: EKCalendar?
    
    override init() {
        
        super.init()
        verifyUserEventAuthorization()
        retrieveApplicationCalendar()
    }
    
    
    func calendars() -> [EKCalendar] {
        
        return store.calendarsForEntityType(.Event)
    }
    
    
    func events(timePeriod: DTTimePeriod, calendarIdentifiers: [String]) -> [EKEvent]? {
        
        // Find each calendar
        
        var calendars = [EKCalendar]()
        
        for id in calendarIdentifiers {
            
            if let cal = store.calendarWithIdentifier(id) {
                calendars.append(cal)
            }
        }
        
        let predicate = store.predicateForEventsWithStartDate(timePeriod.StartDate, endDate: timePeriod.EndDate, calendars: calendars)
        return store.eventsMatchingPredicate(predicate)
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
                    print("Unresolved error \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    
    func verifyUserEventAuthorization() {
        
        switch EKEventStore.authorizationStatusForEntityType(EKEntityType.Event) {
        case .NotDetermined:
            store.requestAccessToEntityType(.Event, completion: { granted, error in
                switch granted {
                case true: print("Granted Access to calendar")
                case false: print("NOT Granted Access to calendar")
                }
            })
        case .Authorized: print("Access to calendar is Authorized")
        store.requestAccessToEntityType(.Event, completion: { (success, error) -> Void in
            
        })
            
        case .Denied: print("Access to calendar is denied")
        case .Restricted: print("Access to calendar is Restricted")
        }
    }
}