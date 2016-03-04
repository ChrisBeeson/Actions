//
//  EventDurationRulePresenter.swift
//  Filament
//
//  Created by Chris Beeson on 22/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

public class TransitionDurationWithVarianceRulePresenter : RulePresenter {
    
    var duration : Int  {
        get {
            return (rule as! TransitionDurationWithVariance).eventStartsInDuration.amount
        }
        set {
            (rule as! TransitionDurationWithVariance).eventStartsInDuration.amount = newValue
        }
    }
    
    var durationUnit : UInt {
        get {
            return (rule as! TransitionDurationWithVariance).eventStartsInDuration.unit.rawValue
        }
        set {
            (rule as! TransitionDurationWithVariance).eventStartsInDuration.unit = DTTimePeriodSize(rawValue: newValue)!
            informDelegatesOfChangesToContent()
        }
    }
    
    var variance : Int  {
        get {
            return (rule as! TransitionDurationWithVariance).variance.amount
        }
        set {
            (rule as! TransitionDurationWithVariance).variance.amount = newValue
        }
    }
    
    var varianceUnit : UInt {
        get {
            return (rule as! TransitionDurationWithVariance).variance.unit.rawValue
        }
        set {
            (rule as! TransitionDurationWithVariance).variance.unit = DTTimePeriodSize(rawValue: newValue)!
            informDelegatesOfChangesToContent()
        }
    }
    
    public override func detailViewController() -> RuleViewController {
        
        if ruleViewController == nil {
            ruleViewController = DurationWithVarianceViewController(nibName:"DurationWithVarianceViewController", bundle: NSBundle(identifier:"com.andris.FilamentKit"))!
            ruleViewController!.rulePresenter = self
        }
        
        return ruleViewController!
    }
}