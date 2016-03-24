//
//  File.swift
//  Filament
//
//  Created by Chris on 9/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation


// This is for classes that use rules, and want to know what rules are available to them

public protocol RuleAvailabiltiy {
    
    var rules:[Rule] { get }
    var type:NodeType { get }
}


extension RuleAvailabiltiy {
    
    public func availableRulePresenters() -> [RulePresenter] {
        
        var allRules = Rule.RegisteredRuleClasses()
        
        for aRule in allRules {
            for rule in self.rules {
                if aRule.className == rule.className {
                    allRules = allRules.filter{ $0.className != rule.className }
                }
            }
        }
        
        allRules = allRules.filter{ $0.availableToNodeType.contains(self.type) }
        
        return allRules.map{ RulePresenter(rule: $0) }
    }
    
    
    public func currentRulePresenters() -> [RulePresenter] {
        
        var presenters = [RulePresenter]()
        for rule in self.rules {
            presenters.append(RulePresenter.makeRulePresenter(rule))
        }
        return presenters
    }
    
}


