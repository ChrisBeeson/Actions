//
//  SolverTests.swift
//  Filament
//
//  Created by Chris on 12/10/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import XCTest

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
        
        // Simple
        // Event starts in 1 hour, give or take 15 min
        // Event Dur is 30, min 15
        
        let rules:[Rule] = [EventDuration(), EventStartsInTimeFromNow()]
        
        let output = Solver.calculateEventPeriod(NSDate.dateFromString("2015-1-1 10:00:00"), rules: rules)
        XCTAssert(output.solved)
        XCTAssert(output.period!.StartDate!.isEqualToDate(NSDate.dateFromString("2015-1-1 10:00:00")))
        XCTAssert(output.period!.EndDate!.isEqualToDate(NSDate.dateFromString("2015-1-1 10:30:00")))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}

/*

public struct DummyAvoids: Rule {

    public var avoidPeriods: [DTTimePeriod]?
    
}
*/
