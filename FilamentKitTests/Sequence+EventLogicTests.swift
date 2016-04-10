//
//  InstanceTests.swift
//  Filament
//
//  Created by Chris Beeson on 27/10/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import XCTest

class EventLogicTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSolveSequenceForwards() {
        
        let actionNodes = [Node(text: "Action 1", type: .Action, rules: nil), Node(text: "Action 2", type: .Action, rules: nil), Node(text: "Action 3", type: .Action, rules: nil)]
        let sequence = Sequence(name: "Sequence Test", actionNodes: actionNodes)
        sequence.date =  NSDate.dateFromString("2015-1-1 10:00:00")
        
        let result = sequence.SolveSequence { (node, state, errors) in
            
        }
        
        XCTAssert(result == true)
        
        for node in sequence.actionNodes {
            print("\(node.title) \(node.event?.startDate) \(node.event?.endDate)")
        }
        
        XCTAssert(sequence.actionNodes[0].event!.startDate.isEqualToDate(NSDate.dateFromString("2015-1-1 10:00:00")))
        XCTAssert(sequence.actionNodes[0].event!.endDate.isEqualToDate(NSDate.dateFromString("2015-1-1 10:30:00")))
        XCTAssert(sequence.actionNodes[1].event!.startDate.isEqualToDate(NSDate.dateFromString("2015-1-1 11:30:00")))
        XCTAssert(sequence.actionNodes[1].event!.endDate.isEqualToDate(NSDate.dateFromString("2015-1-1 12:00:00")))
        XCTAssert(sequence.actionNodes[2].event!.startDate.isEqualToDate(NSDate.dateFromString("2015-1-1 13:00:00")))
    }
    
    
    func testSolveSequenceBackwards() {
        
        let actionNodes = [Node(text: "Action 1", type: .Action, rules: nil), Node(text: "Action 2", type: .Action, rules: nil), Node(text: "Action 3", type: .Action, rules: nil)]
        let sequence = Sequence(name: "Sequence Test", actionNodes: actionNodes)
        sequence.date =  NSDate.dateFromString("2015-1-1 10:00:00")
        sequence.timeDirection = .Backward
        
        let result = sequence.SolveSequence{ (node, state, errors) in
        }

        XCTAssert(result == true)
        
        for node in sequence.actionNodes {
            print("\(node.title) \(node.event?.startDate) \(node.event?.endDate)")
        }

        XCTAssert(sequence.actionNodes[0].event!.startDate.isEqualToDate(NSDate.dateFromString("2015-1-1 06:30:00")))
        XCTAssert(sequence.actionNodes[0].event!.endDate.isEqualToDate(NSDate.dateFromString("2015-1-1 07:00:00")))
        XCTAssert(sequence.actionNodes[1].event!.startDate.isEqualToDate(NSDate.dateFromString("2015-1-1 08:00:00")))
        XCTAssert(sequence.actionNodes[1].event!.endDate.isEqualToDate(NSDate.dateFromString("2015-1-1 08:30:00")))
        XCTAssert(sequence.actionNodes[2].event!.startDate.isEqualToDate(NSDate.dateFromString("2015-1-1 09:30:00")))
    }
}
