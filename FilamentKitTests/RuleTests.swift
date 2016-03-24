//
//  RuleTests.swift
//  Filament
//
//  Created by Chris Beeson on 12/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import XCTest
import DateTools
import FilamentKit

class RuleTests: XCTestCase {
    
    var sequence:Sequence = Sequence()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testTransitionDurationWithVariance() {
        
        // TimeEvent starts in 1 hour, give or take 15 min
        
        let rule = TransitionDurationWithVariance()
        rule.inputDate = NSDate.dateFromString("2015-1-1 10:00:00")
        XCTAssert(rule.eventPreferedStartDate!.isEqualToDate(NSDate.dateFromString("2015-1-1 11:00:00")))
        
        var window = rule.eventStartTimeWindow!
        XCTAssert(window.StartDate.isEqualToDate(NSDate.dateFromString("2015-1-1 10:45:00")))
        XCTAssert(window.EndDate.isEqualToDate(NSDate.dateFromString("2015-1-1 11:15:00")))
        
        //  TimeEvent starts in 30 mins, give or take 5 min
        rule.eventStartsInDuration = TimeSize(unit: .Minute, amount: 30)
        rule.variance = TimeSize(unit: .Minute, amount: 5)
        window = rule.eventStartTimeWindow!
        XCTAssert(window.StartDate.isEqualToDate(NSDate.dateFromString("2015-1-1 10:25:00")))
        XCTAssert(window.EndDate.isEqualToDate(NSDate.dateFromString("2015-1-1 10:35:00")))
        
        //  TimeEvent starts in 1 day, give or take 1 hour
        rule.eventStartsInDuration = TimeSize(unit: .Day, amount: 1)
        rule.variance = TimeSize(unit: .Hour, amount: 1)
        window = rule.eventStartTimeWindow!
        XCTAssert(window.StartDate.isEqualToDate(NSDate.dateFromString("2015-1-2 09:00:00")))
        XCTAssert(window.EndDate.isEqualToDate(NSDate.dateFromString("2015-1-2 11:00:00")))
        
        //  TimeEvent starts in 1 week, give or take 1 day
        rule.eventStartsInDuration = TimeSize(unit: .Week, amount: 1)
        rule.variance = TimeSize(unit: .Day, amount: 1)
        window = rule.eventStartTimeWindow!
        XCTAssert(window.StartDate.isEqualToDate(NSDate.dateFromString("2015-1-7 10:00:00")))
        XCTAssert(window.EndDate.isEqualToDate(NSDate.dateFromString("2015-1-9 10:00:00")))
        
        //  TimeEvent starts in 1 month, give or take 3 days
        rule.eventStartsInDuration = TimeSize(unit: .Month, amount: 1)
        rule.variance = TimeSize(unit: .Day, amount: 3)
        window = rule.eventStartTimeWindow!
        XCTAssert(window.StartDate.isEqualToDate(NSDate.dateFromString("2015-1-29 10:00:00")))
        XCTAssert(window.EndDate.isEqualToDate(NSDate.dateFromString("2015-2-4 10:00:00")))
    }
    
    func testWorkingWeekRule() {
        let rule = WorkingWeekRule()
        rule.interestPeriod = DTTimePeriod(startDate: NSDate.dateFromString("2015-1-1 08:00:00"), endDate:NSDate.dateFromString("2015-1-1 19:00:00"))
        let avoidPeriods = rule.avoidPeriods
        // print("Avoid Periods :")
        //avoidPeriods?.forEach{ print($0.log()) }
        
        XCTAssertNotNil(avoidPeriods)
        XCTAssert(avoidPeriods!.count == 3)
        
        let beforeWork = avoidPeriods![0]
        //print("beforeWork: \(beforeWork.log())")
        XCTAssert(beforeWork.StartDate!.isEqualToDate(NSDate(string: "2015-01-01 00:00", formatString: "YYYY-MM-DD HH:mm")))
        XCTAssert(beforeWork.EndDate!.isEqualToDate(NSDate(string: "2015-01-01 08:59", formatString: "YYYY-MM-DD HH:mm")))

        let afterWork = avoidPeriods![1]
        // print("AfterWork:\(afterWork.log())")
        XCTAssert(afterWork.StartDate!.isEqualToDate(NSDate(string: "2015-01-01 17:30", formatString: "YYYY-MM-DD HH:mm")))
        XCTAssert(afterWork.EndDate!.isEqualToDate(NSDate(string: "2015-01-01 23:59", formatString: "YYYY-MM-DD HH:mm")))
        
        let lunch = avoidPeriods![2]
        // print(lunch.log())
        XCTAssert(lunch.StartDate!.isEqualToDate(NSDate(string: "2015-01-01 12:30", formatString: "YYYY-MM-DD HH:mm")))
        XCTAssert(lunch.EndDate!.isEqualToDate(NSDate(string: "2015-01-01 13:29", formatString: "YYYY-MM-DD HH:mm")))
    }
    
}