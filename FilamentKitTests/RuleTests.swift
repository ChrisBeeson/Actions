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
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        /*
        let actionNodes = [Node(text: "Action 1", type: .Action, rules: nil), Node(text: "Action 2", type: .Action, rules: nil)]
        
        sequence = Sequence(name: "Sequence Test", actionNodes: actionNodes)
*/
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
}