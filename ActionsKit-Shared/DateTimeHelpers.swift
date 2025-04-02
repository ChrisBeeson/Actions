//
//  DateTimeHelpers.swift
//  Actions
//
//  Created by Chris Beeson on 20/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

extension Date {
    
    static func combineDateWithTime(_ date: Date, time: Date) -> Date {
        
        let calendar = Foundation.Calendar.current
        let dateComponents = (calendar as NSCalendar).components([.year, .month, .day], from: date)
        let timeComponents = (calendar as NSCalendar).components([.hour, .minute, .second], from: time)
        
        var components = DateComponents()
        components.year = dateComponents.year
        components.month = dateComponents.month
        components.day = dateComponents.day
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = timeComponents.second
        
        return calendar.date(from: components)!
    }
}
