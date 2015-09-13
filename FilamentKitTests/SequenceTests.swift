//
//  SequenceTests.swift
//  Filament
//
//  Created by Chris Beeson on 6/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import XCTest
import FilamentKit

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
    
    
    func testAllNodes() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        sequence!.logAllNodes()
        
         XCTAssert(sequence!.validSequence() == true)
    }
    
    
    func testInsertNodes() {
        
        sequence!.insertActionNode(Node(text: "End", type: .Action, rules: nil))
        XCTAssert(sequence!.validSequence() == true)
        
        sequence!.insertActionNode(Node(text: "Beginning", type: .Action, rules: nil),index: 0)
        XCTAssert(sequence!.validSequence() == true)
        
        sequence!.insertActionNode(Node(text: "Middle", type: .Action, rules: nil),index: 2)
        XCTAssert(sequence!.validSequence() == true)
        
        sequence!.logAllNodes()
    }
    
    func testValidSequence() {
        
        let nodes = sequence!.allNodes()
        nodes[0].rightTransitionNode = nil
        XCTAssert(sequence!.validSequence() == false)
    }
    

    func testValidSequence2() {
        
        let nodes = sequence!.allNodes()
        nodes[nodes.count-1].leftTransitionNode = nil
        XCTAssert(sequence!.validSequence() == false)
    }
    
    func testValidSequence3(){
        
        let nodes = sequence!.allNodes()
        nodes[0].type = .Transition
        XCTAssert(sequence!.validSequence() == false)
    }
    
    func testDelete () {
        
        let nodeToDelete = sequence!.allNodes()[2]
        // let index = sequence!.allNodes().indexOf(nodeToDelete)
        sequence!.removeActionNode(nodeToDelete)
         sequence!.logAllNodes()
        XCTAssert(sequence!.validSequence() == true)
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
