//
//  DateToolsExtensionsTest.swift
//  Actions
//
//  Created by Chris Beeson on 3/10/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import XCTest
import Foundation
import DateTools
import ActionsKit

class DateToolExtensionsTests: XCTestCase {

    // create dates using date from format yyyy-MM-dd HH:mm:ss
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testFlattenAndVoidPeriods() {
        
        // Create Periods
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // Create 1 event from 3 overlaps
        
        let p1 = DTTimePeriod()
        p1.StartDate = dateFormatter.dateFromString("2015-1-1 10:00:00")
        p1.EndDate = dateFormatter.dateFromString("2015-1-1 10:01:00")
    
        let p2 = DTTimePeriod()
        p2.StartDate = dateFormatter.dateFromString("2015-1-1 10:01:10")
        p2.EndDate = dateFormatter.dateFromString("2015-1-1 10:02:00")
        
        let p3 = DTTimePeriod()
        p3.StartDate = dateFormatter.dateFromString("2015-1-1 10:00:30")
        p3.EndDate = dateFormatter.dateFromString("2015-1-1 10:01:30")
        
        // create a 2nd from 2 overlaps
        
        let p4 = DTTimePeriod()
        p4.StartDate = dateFormatter.dateFromString("2015-1-1 10:05:00")
        p4.EndDate = dateFormatter.dateFromString("2015-1-1 10:05:30")
        
        let p5 = DTTimePeriod()
        p5.StartDate = dateFormatter.dateFromString("2015-1-1 10:05:10")
        p5.EndDate = dateFormatter.dateFromString("2015-1-1 10:07:00")
        
        // a lone period
        
        let p6 = DTTimePeriod()
        p6.StartDate = dateFormatter.dateFromString("2015-1-2 12:00:00")
        p6.EndDate = dateFormatter.dateFromString("2015-1-2 13:00:00")
        
        // just another overlap for good luck
        
        let p7 = DTTimePeriod()
        p7.StartDate = dateFormatter.dateFromString("2015-10-2 12:00:00")
        p7.EndDate = dateFormatter.dateFromString("2015-10-2 13:00:00")
        
        let p8 = DTTimePeriod()
        p8.StartDate = dateFormatter.dateFromString("2015-10-2 12:10:00")
        p8.EndDate = dateFormatter.dateFromString("2015-10-2 13:40:00")
        
        let collection = DTTimePeriodCollection()
        collection.addTimePeriod(p1)
        collection.addTimePeriod(p6)
        collection.addTimePeriod(p3)
        collection.addTimePeriod(p2)
        collection.addTimePeriod(p8)
        collection.addTimePeriod(p4)
        collection.addTimePeriod(p7)
        collection.addTimePeriod(p5)
        collection.flatten()
        XCTAssert(collection.periods()!.count == 4 , "Failed Flattening Timespans")
        
        let interestPeriod = DTTimePeriod(startDate: NSDate.dateFromString("2014-11-30 09:00:00"), endDate: NSDate.dateFromString("2015-11-2 14:00:00"))
        let void = collection.voidPeriods(interestPeriod)
        XCTAssert(void.count() == 5 , "Failed find the correct amount of Void Periods - got \(void.count())")
    }
    
    
    func testSubtractTimesize() {
        
    }
    
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}