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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // Create 1 event from 3 overlaps
        
        let p1 = DTTimePeriod()
        p1.startDate = dateFormatter.date(from: "2015-1-1 10:00:00")
        p1.endDate = dateFormatter.date(from: "2015-1-1 10:01:00")
    
        let p2 = DTTimePeriod()
        p2.startDate = dateFormatter.date(from: "2015-1-1 10:01:10")
        p2.endDate = dateFormatter.date(from: "2015-1-1 10:02:00")
        
        let p3 = DTTimePeriod()
        p3.startDate = dateFormatter.date(from: "2015-1-1 10:00:30")
        p3.endDate = dateFormatter.date(from: "2015-1-1 10:01:30")
        
        // create a 2nd from 2 overlaps
        
        let p4 = DTTimePeriod()
        p4.startDate = dateFormatter.date(from: "2015-1-1 10:05:00")
        p4.endDate = dateFormatter.date(from: "2015-1-1 10:05:30")
        
        let p5 = DTTimePeriod()
        p5.startDate = dateFormatter.date(from: "2015-1-1 10:05:10")
        p5.endDate = dateFormatter.date(from: "2015-1-1 10:07:00")
        
        // a lone period
        
        let p6 = DTTimePeriod()
        p6.startDate = dateFormatter.date(from: "2015-1-2 12:00:00")
        p6.endDate = dateFormatter.date(from: "2015-1-2 13:00:00")
        
        // just another overlap for good luck
        
        let p7 = DTTimePeriod()
        p7.startDate = dateFormatter.date(from: "2015-10-2 12:00:00")
        p7.endDate = dateFormatter.date(from: "2015-10-2 13:00:00")
        
        let p8 = DTTimePeriod()
        p8.startDate = dateFormatter.date(from: "2015-10-2 12:10:00")
        p8.endDate = dateFormatter.date(from: "2015-10-2 13:40:00")
        
        let collection = DTTimePeriodCollection()
        collection.add(p1)
        collection.add(p6)
        collection.add(p3)
        collection.add(p2)
        collection.add(p8)
        collection.add(p4)
        collection.add(p7)
        collection.add(p5)
        collection.flatten()
        XCTAssert(collection.periods()!.count == 4 , "Failed Flattening Timespans")
        
        let interestPeriod = DTTimePeriod(start: Date.dateFromString("2014-11-30 09:00:00"), end: Date.dateFromString("2015-11-2 14:00:00"))
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
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
