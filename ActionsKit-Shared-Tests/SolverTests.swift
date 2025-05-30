//
//  SolverTests.swift
//  Actions
//
//  Created by Chris on 12/10/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import XCTest
import DateTools

class SolverTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCalculateEventPeriod() {
        
        // Simple Just fits in the hole
        // CalendarEvent starts in 1 hour, give or take 15 min
        // CalendarEvent Dur is 30, min 15
        
        var rules:[Rule] = [EventDurationWithMinimumDuration(), TransitionDurationWithVariance()]
        let node = Node()
        
        var output = Solver.calculateEventPeriod(Date.dateFromString("2015-1-1 10:00:00"), direction: .Forward, node:node, rules: rules)
        XCTAssert(output.solved)
        XCTAssert(output.period!.StartDate!.isEqualToDate(Date.dateFromString("2015-1-1 11:00:00")))
        XCTAssert(output.period!.EndDate!.isEqualToDate(Date.dateFromString("2015-1-1 11:30:00")))
        
        // Harder there is something right at our prefered period, but still will fit the average size
        let avoid = DummyAvoids()
        avoid.avoidPeriods = [AvoidPeriod(period: DTTimePeriod(start: Date.dateFromString("2015-1-1 11:00:00"), end: Date.dateFromString("2015-1-1 11:10:00")))]
        rules.append(avoid)
        output = Solver.calculateEventPeriod(Date.dateFromString("2015-1-1 10:00:00"),direction: .Forward, node:node, rules: rules)
        XCTAssert(output.solved)
        XCTAssert(output.period!.StartDate!.isEqualToDate(Date.dateFromString("2015-1-1 11:10:00")))
        XCTAssert(output.period!.EndDate!.isEqualToDate(Date.dateFromString("2015-1-1 11:40:00")))
        
        // even harder
        let avoid2 = DummyAvoids()
        avoid2.avoidPeriods = [AvoidPeriod(period: DTTimePeriod(start: Date.dateFromString("2015-1-1 11:25:00"), end: Date.dateFromString("2015-1-1 11:30:00")))]
        rules.append(avoid2)
        output = Solver.calculateEventPeriod(Date.dateFromString("2015-1-1 10:00:00"),direction: .Forward, node:node, rules: rules)
        XCTAssert(output.solved)
        XCTAssert(output.period!.StartDate!.isEqualToDate(Date.dateFromString("2015-1-1 11:10:00")))
        XCTAssert(output.period!.EndDate!.isEqualToDate(Date.dateFromString("2015-1-1 11:25:00")))
        
        // impossible
        let avoid3 = DummyAvoids(), avoid4 = DummyAvoids(), avoid5 = DummyAvoids()
        avoid3.avoidPeriods = [AvoidPeriod(period: DTTimePeriod(start: Date.dateFromString("2015-1-1 11:35:00"), end: Date.dateFromString("2015-1-1 11:38:00")))]
        rules.append(avoid3)
        avoid4.avoidPeriods = [AvoidPeriod(period: DTTimePeriod(start: Date.dateFromString("2015-1-1 10:50:00"), end: Date.dateFromString("2015-1-1 10:52:00")))]
        rules.append(avoid4)
        avoid5.avoidPeriods = [AvoidPeriod(period: DTTimePeriod(start: Date.dateFromString("2015-1-1 11:15:00"), end: Date.dateFromString("2015-1-1 11:20:00")))]
        rules.append(avoid5)
        output = Solver.calculateEventPeriod(Date.dateFromString("2015-1-1 10:00:00"),direction: .Forward, node:node, rules: rules)
        XCTAssert(output.solved == false)
    }

    
    func testCalculateEventPeriodWithTransitionDurationWithVariance () {
        
        let durationWithNoVariance = TransitionDurationWithVariance()
        durationWithNoVariance.eventStartsInDuration = Timesize(unit: .Hour, amount: 1)
        durationWithNoVariance.variance = Timesize(unit: .Second, amount: 0)
        
        var rules:[Rule] = [EventDurationWithMinimumDuration(), durationWithNoVariance]
        let node = Node()
        
        var output = Solver.calculateEventPeriod(Date.dateFromString("2015-1-1 10:00:00"),direction: .Forward, node:node, rules: rules)
        XCTAssert(output.solved == true)
        XCTAssert(output.period!.StartDate!.isEqualToDate(Date.dateFromString("2015-1-1 11:00:00")))
        
        // put something right in the way, as variance is 0 it should just fail.
        
        let avoid = DummyAvoids()
        avoid.avoidPeriods = [AvoidPeriod(period:DTTimePeriod(start: Date.dateFromString("2015-1-1 10:59:00"), end: Date.dateFromString("2015-1-1 11:05:00")))]
        rules.append(avoid)
        
         output = Solver.calculateEventPeriod(Date.dateFromString("2015-1-1 10:00:00"),direction: .Forward, node:node, rules: rules)
         XCTAssert(output.solved == false)
    }
    
    
    func testCalculateEventPeriodWithWorkingWeek() {
        
        // We have 3 rules... 1. the event duration 2. the startTime, and 3. the avoid periods generated by the working week.
        
        let workingWeek = WorkingWeekRule()
        
        let eventDuration = EventDurationWithMinimumDuration()
        eventDuration.minDuration = Timesize(unit: .Minute, amount: 30)
        
        let transitionDuration = TransitionDurationWithVariance()
        
        //  let dummyInterest = DummyAvoids()
        //dummyInterest.interestPeriod = DTTimePeriod(startDate: NSDate.dateFromString("2015-1-1 07:00:00"), endDate: NSDate.dateFromString("2015-1-1 22:50:00"))
    
        let rules:[Rule] = [EventDurationWithMinimumDuration(), transitionDuration, workingWeek]
        let node = Node()
    
        // First, lets test the start time by trying to start an event before the work hours start time
        
        var output = Solver.calculateEventPeriod(Date(string: "2015-01-01 07:50", formatString: "YYYY-MM-DD hh:mm"),direction: .Forward,node:node, rules: rules)
        
        XCTAssert(output.solved == true)
        XCTAssert(output.period!.StartDate!.isEqualToDate(Date(string: "2015-01-01 09:00", formatString: "YYYY-MM-DD hh:mm")))
        
        // Next event clashes with lunch
        output = Solver.calculateEventPeriod(Date(string: "2015-01-01 12:20", formatString: "YYYY-MM-DD HH:mm"),direction: .Forward,node:node, rules: rules)
        XCTAssert(output.solved == true)
        XCTAssert(output.period!.StartDate!.isEqualToDate(Date(string: "2015-01-01 13:30", formatString: "YYYY-MM-DD HH:mm")))
        
        // lets put an event at the end of the day.  Force it to start at 9am the next day...
        
        let greaterThan = GreaterThanLessThanRule()
        greaterThan.greaterThan = Timesize(unit: .Hour, amount: 2)
        greaterThan.lessThan = Timesize(unit: .Hour, amount: 16)
        
        let newRules = [EventDurationWithMinimumDuration(), greaterThan, workingWeek]
        output = Solver.calculateEventPeriod(Date(string: "2015-01-01 17:25", formatString: "YYYY-MM-DD HH:mm"), direction: .Forward, node:node, rules: newRules)
        XCTAssert(output.solved == true)
        XCTAssert(output.period!.StartDate!.isEqualToDate(Date(string: "2015-01-02 09:00", formatString: "YYYY-MM-DD HH:mm")))
    }
    
    
    func testBackwards() {
        
        // event duration is 30 mins
        // an hour before the input date
        
        let rules:[Rule] = [EventDurationWithMinimumDuration(), TransitionDurationWithVariance()]
        let node = Node()
        
        let output = Solver.calculateEventPeriod(Date(string: "2015-01-01 10:00", formatString: "YYYY-MM-DD HH:mm"), direction: .Backward, node:node, rules: rules)
        print(output.period?.log())
        XCTAssert(output.solved)
        XCTAssert(output.period!.StartDate!.isEqualToDate(Date(string: "2015-01-01 08:30", formatString: "YYYY-MM-DD HH:mm")))
        XCTAssert(output.period!.EndDate!.isEqualToDate(Date(string: "2015-01-01 09:00", formatString: "YYYY-MM-DD HH:mm")))
    }
}

open class DummyAvoids: Rule {
    open override var inputDate: Date? {get { return Date.distantPast } set {  }}
}

