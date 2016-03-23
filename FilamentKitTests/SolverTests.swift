//
//  SolverTests.swift
//  Filament
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
        // TimeEvent starts in 1 hour, give or take 15 min
        // TimeEvent Dur is 30, min 15
        
        var rules:[Rule] = [EventDurationWithMinimumDuration(), TransitionDurationWithVariance()]
        let node = Node()
        
        var output = Solver.calculateEventPeriod(NSDate.dateFromString("2015-1-1 10:00:00"),node:node, rules: rules)
        XCTAssert(output.solved)
        XCTAssert(output.period!.StartDate!.isEqualToDate(NSDate.dateFromString("2015-1-1 11:00:00")))
        XCTAssert(output.period!.EndDate!.isEqualToDate(NSDate.dateFromString("2015-1-1 11:30:00")))
        
        // Harder there is something right at our prefered period, but still will fit the average size
        
        let avoid = DummyAvoids()
        avoid.avoidPeriods = [DTTimePeriod(startDate: NSDate.dateFromString("2015-1-1 11:00:00"), endDate: NSDate.dateFromString("2015-1-1 11:10:00"))]
        rules.append(avoid)
        
        output = Solver.calculateEventPeriod(NSDate.dateFromString("2015-1-1 10:00:00"),node:node, rules: rules)
        XCTAssert(output.solved)
        XCTAssert(output.period!.StartDate!.isEqualToDate(NSDate.dateFromString("2015-1-1 11:10:00")))
        XCTAssert(output.period!.EndDate!.isEqualToDate(NSDate.dateFromString("2015-1-1 11:40:00")))
        
        
        // even harder
        
        let avoid2 = DummyAvoids()
        avoid2.avoidPeriods = [DTTimePeriod(startDate: NSDate.dateFromString("2015-1-1 11:25:00"), endDate: NSDate.dateFromString("2015-1-1 11:30:00"))]
        rules.append(avoid2)
        
        output = Solver.calculateEventPeriod(NSDate.dateFromString("2015-1-1 10:00:00"),node:node, rules: rules)
        XCTAssert(output.solved)
        XCTAssert(output.period!.StartDate!.isEqualToDate(NSDate.dateFromString("2015-1-1 11:10:00")))
        XCTAssert(output.period!.EndDate!.isEqualToDate(NSDate.dateFromString("2015-1-1 11:25:00")))
        
        // impossible
        
        let avoid3 = DummyAvoids(), avoid4 = DummyAvoids(), avoid5 = DummyAvoids()
        avoid3.avoidPeriods = [DTTimePeriod(startDate: NSDate.dateFromString("2015-1-1 11:35:00"), endDate: NSDate.dateFromString("2015-1-1 11:38:00"))]
        rules.append(avoid3)

        avoid4.avoidPeriods = [DTTimePeriod(startDate: NSDate.dateFromString("2015-1-1 10:50:00"), endDate: NSDate.dateFromString("2015-1-1 10:52:00"))]
        rules.append(avoid4)
        
        avoid5.avoidPeriods = [DTTimePeriod(startDate: NSDate.dateFromString("2015-1-1 11:15:00"), endDate: NSDate.dateFromString("2015-1-1 11:20:00"))]
        rules.append(avoid5)
        
        output = Solver.calculateEventPeriod(NSDate.dateFromString("2015-1-1 10:00:00"),node:node, rules: rules)
        XCTAssert(output.solved == false)
    }

    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
*/

}



public class DummyAvoids: Rule {

    // public override var avoidPeriods: [DTTimePeriod]?
    
    public override var inputDate: NSDate? {get { return NSDate.distantPast() } set {  }}
    
}

