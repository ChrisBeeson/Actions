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
    var sequencePresenter: SequencePresenter?
    var ruleViewController : RuleViewController?
    
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
            
        case "FilamentKit.EventDurationWithMinimumDuration":
            return EventDurationWithMinimumDurationRulePresenter(rule: rule)
            
        case "FilamentKit.TransitionDurationWithVariance":
            return TransitionDurationWithVarianceRulePresenter(rule: rule)
            
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
    
    func informDelegatesOfChangesToContent() {
        
        delegates.forEach { $0.rulePresenterDidChangeContent(self) }
    }
    
    
    
    public func detailViewController() -> RuleViewController {
        fatalError("This needs to be subclassed")
    }
}