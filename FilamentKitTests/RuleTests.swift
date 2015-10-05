//
//  RuleTests.swift
//  Filament
//
//  Created by Chris Beeson on 12/09/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import XCTest
import FilamentKit

class RuleTests: XCTestCase {
    
    var sequence:Sequence = Sequence()
    
    override func setUp() {
        
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let actionNodes = [Node(text: "Action 1", type: .Action, rules: nil), Node(text: "Action 2", type: .Action, rules: nil)]
        
        sequence = Sequence(name: "Sequence Test", actionNodes: actionNodes)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testFixedDurationRule() {
        
        // There are two actions
        
        /*
        
        let instance = sequence.instance("Instance 1")
        
        instance.startDate = NSDate(timeIntervalSinceNow: 0)
 
        instance.process()

*/
        
    }
}