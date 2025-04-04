//
//  File.swift
//  Actions
//
//  Created by Chris on 9/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

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
        
        let rulesToReturn = allRules.map{ RulePresenter(rule: $0) }
        rulesToReturn.forEach{$0.useDetailName = false}
        return rulesToReturn
    }
    
    
    public func currentRulePresenters() -> [RulePresenter] {
        var presenters = [RulePresenter]()
        for rule in self.rules {
            presenters.append(RulePresenter.makeRulePresenter(rule))
        }
        presenters.forEach{$0.useDetailName = true}
        return presenters
    }
    
    
    public func wouldAcceptRulePresenter(_ presenter:RulePresenter, allowDuplicates: Bool) -> Bool {
        if presenter.availableToNodeType.contains(type) ==  false { return false }
        if allowDuplicates == false {
            for rule in self.rules {
                if presenter.rule.className == rule.className { return false }
            }
        }
        return true
    }
}
