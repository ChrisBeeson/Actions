//
//  EventDurationRulePresenter.swift
//  Actions
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
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    var durationUnit : UInt {
        get {
            return (rule as! TransitionDurationWithVariance).eventStartsInDuration.unit.rawValue
        }
        set {
            (rule as! TransitionDurationWithVariance).eventStartsInDuration.unit = DTTimePeriodSize(rawValue: newValue)!
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    var variance : Int  {
        get {
            return (rule as! TransitionDurationWithVariance).variance.amount
        }
        set {
            (rule as! TransitionDurationWithVariance).variance.amount = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    var varianceUnit : UInt {
        get {
            return (rule as! TransitionDurationWithVariance).variance.unit.rawValue
        }
        set {
            (rule as! TransitionDurationWithVariance).variance.unit = DTTimePeriodSize(rawValue: newValue)!
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    public override func detailViewController() -> RuleViewController {
        
        if ruleViewController == nil {
            ruleViewController = DurationWithVarianceViewController(nibName:"DurationWithVarianceViewController", bundle: NSBundle(identifier:"com.andris.ActionsKit"))!
            ruleViewController!.rulePresenter = self
        }
        
        return ruleViewController!
    }
}