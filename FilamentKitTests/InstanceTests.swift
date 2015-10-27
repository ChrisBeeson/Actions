//
//  InstanceTests.swift
//  Filament
//
//  Created by Chris Beeson on 27/10/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import XCTest

class InstanceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func simpleEventGeneration() {
        
        // Build Sequence
        
        let Action1 = Node(text: "Action 1", type: .Action, rules: nil)  // Actions come with default duration
        
        
        
        let actionNodes = [Node(text: "Action 1", type: .Action, rules: nil), Node(text: "Action 2", type: .Action, rules: nil), Node(text: "Action 3", type: .Action, rules: nil)]
        
        sequence = Sequence(name: "Sequence Test", actionNodes: actionNodes)
        
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }



}
