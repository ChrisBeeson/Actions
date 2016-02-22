//
//  RulePresenter.swift
//  Filament
//
//  Created by Chris Beeson on 22/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class RulePresenter : NSObject {
    
    private var delegates = [RulePresenterDelegate]()
    var undoManager: NSUndoManager?
    
    var rule : Rule
    
    init(rule: Rule) {
        self.rule = rule
        super.init()
    }
    
    var name : NSString {
        return rule.name
    }
    
    
    //MARK: Factory class
    
    class func rulePresenterForRule(rule: Rule) -> RulePresenter {
        
        switch rule.className {
            
        case "FilamentKit.EventDuration":
            return EventDurationRulePresenter(rule: rule)
            
        case "FilamentKit.EventStartsInTimeFromNow":
            return EventStartsInTimeFromNowRulePresenter(rule: rule)
            
        default:
            fatalError("Unable to find rule presenter for rule \(rule.className)")
        }
    }
    
    
    
    //MARK: Delegate helpers
    
    public func addDelegate(delegate:RulePresenterDelegate) {
        
        if !delegates.contains({$0 === delegate}) {
            delegates.append(delegate)
        }
    }
    
    public func removeDelegate(delegate:RulePresenterDelegate) {
        
        delegates = delegates.filter { return $0 !== delegate }
    }
    
}