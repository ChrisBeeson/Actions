//
//  DateTimeHelpers.swift
//  Filament
//
//  Created by Chris Beeson on 20/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

extension NSDate {
    

class func combineDateWithTime(date: NSDate, time: NSDate) -> NSDate {
    
    let calendar = NSCalendar.currentCalendar()
    let dateComponents = calendar.components([.Year, .Month, .Day], fromDate: date)
    let timeComponents = calendar.components([.Hour, .Minute, .Second], fromDate: time)
    
    let components = NSDateComponents()
    components.year = dateComponents.year
    components.month = dateComponents.month
    components.day = dateComponents.day
    components.hour = timeComponents.hour
    components.minute = timeComponents.minute
    components.second = timeComponents.second
    
    return calendar.dateFromComponents(components)!
}

}