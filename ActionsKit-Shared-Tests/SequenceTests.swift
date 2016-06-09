//
//  SequenceTests.swift
//  Actions
//
//  Created by Chris Beeson on 6/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import XCTest

class SequenceTests: XCTestCase {
    
    var sequence:Sequence?
    
    override func setUp() {
        
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let actionNodes = [Node(text: "Action 1", type: .Action, rules: nil), Node(text: "Action 2", type: .Action, rules: nil), Node(text: "Action 3", type: .Action, rules: nil)]
        
        sequence = Sequence(name: "Sequence Test", actionNodes: actionNodes)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testchain() {
        
        sequence!.printChain()
        XCTAssert(sequence!.validSequence() == true)

        sequence!.timeDirection = .Backward
        sequence!.printChain()
        XCTAssert(sequence!.validSequence() == true)
    }
    
    func testInsertNodes() {
        
        sequence!.insertActionNode(Node(text: "End", type: .Action, rules: nil))
        XCTAssert(sequence!.validSequence() == true)
        
        sequence!.insertActionNode(Node(text: "Beginning", type: .Action, rules: nil),index: 0)
        XCTAssert(sequence!.validSequence() == true)
        
        sequence!.insertActionNode(Node(text: "Middle", type: .Action, rules: nil),index: 2)
        XCTAssert(sequence!.validSequence() == true)
        
        sequence!.printChain()
        
        sequence!.timeDirection = .Backward
        XCTAssert(sequence!.validSequence() == true)
        
    }
    
    func testValidSequence() {
        
        let nodes = sequence!.nodeChain()
        nodes[0].rightTransitionNode = nil
        XCTAssert(sequence!.validSequence() == false)
    }
    
    
    func testValidSequence2() {
        
        let nodes = sequence!.nodeChain()
        nodes[nodes.count-1].leftTransitionNode = nil
        XCTAssert(sequence!.validSequence() == false)
        
        sequence!.timeDirection = .Backward
        XCTAssert(sequence!.validSequence() == false)
    }
    
    func testValidSequence3(){
        
        let nodes = sequence!.nodeChain()
        nodes[0].type = .Transition
        XCTAssert(sequence!.validSequence() == false)
    }
    
    func testDeleteFirstNode() {
        
        let nodeToDelete = sequence!.nodeChain()[0]
        sequence!.removeActionNode(nodeToDelete)
        sequence!.printChain()
        XCTAssert(sequence!.validSequence() == true)
        
        sequence!.timeDirection = .Backward
        XCTAssert(sequence!.validSequence() == true)
    }
    
    func testDeleteMiddleNode() {
        
        let nodeToDelete = sequence!.nodeChain()[2]
        sequence!.removeActionNode(nodeToDelete)
        sequence!.printChain()
        XCTAssert(sequence!.validSequence() == true)
        
        sequence!.timeDirection = .Backward
        XCTAssert(sequence!.validSequence() == true)
    }
    
    
    
    /// Events
   /*
    func testEventCreation() {
        
        let actionNodes = [Node(text: "Action 1", type: .Action, rules: nil), Node(text: "Action 2", type: .Action, rules: nil), Node(text: "Action 3", type: .Action, rules: nil)]
        
        sequence = Sequence(name: "Sequence Test", actionNodes: actionNodes)
        
        sequence!.startDate = NSDate()
        
        // here goes!
        
        sequence!.SolveSequence()
        
    }
    */
    
    func testEncodingSequence() {
        
        let archivedSequenceData = NSKeyedArchiver.archivedDataWithRootObject(sequence!)
        XCTAssertTrue(archivedSequenceData.length > 0)
    }
    
    func testDecodingSequence() {
        let actionNodes = [Node(text: "Action 1", type: .Action, rules: nil), Node(text: "Action 2", type: .Action, rules: nil), Node(text: "Action 3", type: .Action, rules: nil)]
        let sequence = Sequence(name: "Sequence Test", actionNodes: actionNodes)
        
        let archivedSequenceData = NSKeyedArchiver.archivedDataWithRootObject(sequence)
        let unarchivedSequence = NSKeyedUnarchiver.unarchiveObjectWithData(archivedSequenceData) as? Sequence
        
        XCTAssertNotNil(unarchivedSequence)
        XCTAssertEqual(sequence, unarchivedSequence)
    }
    
    
    /*
    func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measureBlock() {
    // Put the code you want to measure the time of here.
    }
    }
    */
    
}
