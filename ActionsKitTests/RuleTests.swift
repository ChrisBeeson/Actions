//
//  RuleTests.swift
//  Actions
//
//  Created by Chris Beeson on 12/01/2016.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import XCTest
import DateTools
import ActionsKit

class RuleTests: XCTestCase {
    
    var sequence:Sequence = Sequence()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //TODO: Need to update these as AvoidPeriod is a new addition
    

    func testTransitionDurationWithVariance() {
        
        // CalendarEvent starts in 1 hour, give or take 15 min
        
        let rule = TransitionDurationWithVariance()
        rule.inputDate = NSDate.dateFromString("2015-1-1 10:00:00")
        XCTAssert(rule.eventPreferedStartDate!.isEqualToDate(NSDate.dateFromString("2015-1-1 11:00:00")))
        
        var window = rule.eventStartTimeWindow!
        XCTAssert(window.StartDate.isEqualToDate(NSDate.dateFromString("2015-1-1 10:45:00")))
        XCTAssert(window.EndDate.isEqualToDate(NSDate.dateFromString("2015-1-1 11:15:00")))
        
        //  CalendarEvent starts in 30 mins, give or take 5 min
        rule.eventStartsInDuration = Timesize(unit: .Minute, amount: 30)
        rule.variance = Timesize(unit: .Minute, amount: 5)
        window = rule.eventStartTimeWindow!
        XCTAssert(window.StartDate.isEqualToDate(NSDate.dateFromString("2015-1-1 10:25:00")))
        XCTAssert(window.EndDate.isEqualToDate(NSDate.dateFromString("2015-1-1 10:35:00")))
        
        //  CalendarEvent starts in 1 day, give or take 1 hour
        rule.eventStartsInDuration = Timesize(unit: .Day, amount: 1)
        rule.variance = Timesize(unit: .Hour, amount: 1)
        window = rule.eventStartTimeWindow!
        XCTAssert(window.StartDate.isEqualToDate(NSDate.dateFromString("2015-1-2 09:00:00")))
        XCTAssert(window.EndDate.isEqualToDate(NSDate.dateFromString("2015-1-2 11:00:00")))
        
        //  CalendarEvent starts in 1 week, give or take 1 day
        rule.eventStartsInDuration = Timesize(unit: .Week, amount: 1)
        rule.variance = Timesize(unit: .Day, amount: 1)
        window = rule.eventStartTimeWindow!
        XCTAssert(window.StartDate.isEqualToDate(NSDate.dateFromString("2015-1-7 10:00:00")))
        XCTAssert(window.EndDate.isEqualToDate(NSDate.dateFromString("2015-1-9 10:00:00")))
        
        //  CalendarEvent starts in 1 month, give or take 3 days
        rule.eventStartsInDuration = Timesize(unit: .Month, amount: 1)
        rule.variance = Timesize(unit: .Day, amount: 3)
        window = rule.eventStartTimeWindow!
        XCTAssert(window.StartDate.isEqualToDate(NSDate.dateFromString("2015-1-29 10:00:00")))
        XCTAssert(window.EndDate.isEqualToDate(NSDate.dateFromString("2015-2-4 10:00:00")))
    }
    
    func testTransitionDurationWithVarianceBackwards() {
        
        // CalendarEvent starts in 1 hour, give or take 15 min
        
        let rule = TransitionDurationWithVariance()
        rule.inputDate = NSDate.dateFromString("2015-1-1 10:00:00")
        rule.timeDirection = .Backward
        print(rule.eventPreferedStartDate!)
        
        XCTAssert(rule.eventPreferedStartDate!.isEqualToDate(NSDate.dateFromString("2015-1-1 09:00:00")))
    }
    
    func testWorkingWeekRule() {
        let rule = WorkingWeekRule()
        rule.interestPeriod = DTTimePeriod(startDate: NSDate(string: "2015-01-01 08:00", formatString: "YYYY-MM-DD HH:mm"), endDate:NSDate(string: "2015-01-01 19:00", formatString: "YYYY-MM-DD HH:mm"))
        let avoidPeriods = rule.avoidPeriods
        //print("Working Week Generated Avoid Periods :")
        //avoidPeriods?.forEach{ print($0.log()) }
        
        XCTAssertNotNil(avoidPeriods)
        XCTAssert(avoidPeriods!.count == 6)
        
        let beforeWork = avoidPeriods![0]
        //print("beforeWork: \(beforeWork.log())")
        XCTAssert(beforeWork.period.StartDate!.isEqualToDate(NSDate(string: "2015-01-01 00:00", formatString: "YYYY-MM-DD HH:mm")))
        XCTAssert(beforeWork.period.EndDate!.isEqualToDate(NSDate(string: "2015-01-01 09:00", formatString: "YYYY-MM-DD HH:mm")))

        let afterWork = avoidPeriods![1]
        // print("AfterWork:\(afterWork.log())")
        XCTAssert(afterWork.period.StartDate!.isEqualToDate(NSDate(string: "2015-01-01 17:30", formatString: "YYYY-MM-DD HH:mm")))
        XCTAssert(afterWork.period.EndDate!.isEqualToDate(NSDate(string: "2015-01-01 23:59", formatString: "YYYY-MM-DD HH:mm")))
        
        let lunch = avoidPeriods![2]
        // print(lunch.log())
        XCTAssert(lunch.period.StartDate!.isEqualToDate(NSDate(string: "2015-01-01 12:30", formatString: "YYYY-MM-DD HH:mm")))
        XCTAssert(lunch.period.EndDate!.isEqualToDate(NSDate(string: "2015-01-01 13:30", formatString: "YYYY-MM-DD HH:mm")))
        
        let midnightToNextDay = avoidPeriods![3]
        // print(lunch.log())
        XCTAssert(midnightToNextDay.period.StartDate!.isEqualToDate(NSDate(string: "2015-01-02 00:00", formatString: "YYYY-MM-DD HH:mm")))
        XCTAssert(midnightToNextDay.period.EndDate!.isEqualToDate(NSDate(string: "2015-01-02 09:00", formatString: "YYYY-MM-DD HH:mm")))
    }
}