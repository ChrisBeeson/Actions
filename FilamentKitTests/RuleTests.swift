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
    
    

    
    func testEventStartsInTimeFromNow() {
        
        // Event starts in 1 hour, give or take 15 min
        
        let rule = EventStartsInTimeFromNow()
        rule.inputDate = NSDate.dateFromString("2015-1-1 10:00:00")
        XCTAssert(rule.eventPreferedStartDate!.isEqualToDate(NSDate.dateFromString("2015-1-1 11:00:00")))
        
        let window = rule.eventStartTimeWindow!
        XCTAssert(window.StartDate.isEqualToDate(NSDate.dateFromString("2015-1-1 10:45:00")))
        XCTAssert(window.EndDate.isEqualToDate(NSDate.dateFromString("2015-1-1 11:15:00")))
    }
}