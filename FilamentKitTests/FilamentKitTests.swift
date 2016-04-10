//
//  FilamentKitTests.swift
//  FilamentKitTests
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2015 Andris Ltd. All rights reserved.
//

import Cocoa
import XCTest
import ObjectMapper

class FilamentKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testJSONMappingNode() {
     
        let node = Node()
        var results = Mapper().toJSONString(node, prettyPrint: false)
        print(results)
        XCTAssert(results?.isEmpty == false, "Pass")
        
        let transDuration = TransitionDurationWithVariance()
        results = Mapper().toJSONString(transDuration, prettyPrint: false)
        print(results)
        XCTAssert(results?.isEmpty == false, "Pass")
        
        let eventDuration = EventDurationWithMinimumDuration()
        results = Mapper().toJSONString(eventDuration, prettyPrint: false)
        print(results)
        XCTAssert(results?.isEmpty == false, "Pass")
        
        let avoidCal = AvoidCalendarEventsRule()
        results = Mapper().toJSONString(avoidCal, prettyPrint: false)
        print(results)
        XCTAssert(results?.isEmpty == false, "Pass")
        
        let workingWeek = WorkingWeekRule()
        results = Mapper().toJSONString(workingWeek, prettyPrint: false)
        print(results)
        XCTAssert(results?.isEmpty == false, "Pass")
        
        node.rules = [transDuration,eventDuration]
        results = Mapper().toJSONString(node, prettyPrint: false)
        print(results)
        XCTAssert(results?.isEmpty == false, "Pass")
        
        
        
        /*
        let actionNodes = [Node(text: "Action 1", type: .Action, rules: nil)]
        let sequence = Sequence(name: "Sequence Test", actionNodes: actionNodes)
        
        results = Mapper().toJSONString(sequence, prettyPrint: false)
        print(results)
        XCTAssert(results?.isEmpty == false, "Pass")
        */
        
        /*
        let actionNodes = [Node(text: "Action 1", type: .Action, rules: nil), Node(text: "Action 2", type: .Action, rules: nil), Node(text: "Action 3", type: .Action, rules: nil)]
        let sequence = Sequence(name: "Sequence Test", actionNodes: actionNodes)
        results = Mapper().toJSONString(sequence, prettyPrint: false)
        print(results)
        XCTAssert(results?.isEmpty == false, "Pass")
 */
        
    }
    
}
