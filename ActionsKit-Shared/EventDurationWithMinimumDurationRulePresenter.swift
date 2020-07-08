//
//  EventStartsInTimeFromNowRulePresenter.swift
//  Actions
//
//  Created by Chris Beeson on 22/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

open class EventDurationWithMinimumDurationRulePresenter : RulePresenter {
    
    var duration : Int  {
        get {
            return (rule as! EventDurationWithMinimumDuration).duration.amount
        }
        set {
            (rule as! EventDurationWithMinimumDuration).duration.amount = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    var durationUnit : UInt {
        get {
            return (rule as! EventDurationWithMinimumDuration).duration.unit.rawValue
        }
        set {
            (rule as! EventDurationWithMinimumDuration).duration.unit = DTTimePeriodSize(rawValue: newValue)!
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    var minDuration : Int  {
        get {
            return (rule as! EventDurationWithMinimumDuration).minDuration.amount
        }
        set {
            (rule as! EventDurationWithMinimumDuration).minDuration.amount = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    var minDurationUnit : UInt {
        get {
            return (rule as! EventDurationWithMinimumDuration).minDuration.unit.rawValue
        }
        set {
            (rule as! EventDurationWithMinimumDuration).minDuration.unit = DTTimePeriodSize(rawValue: newValue)!
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    open override func detailViewController() -> RuleViewController {
        
        if ruleViewController == nil {
            ruleViewController = EventDurationWithMinimumDurationViewController(nibName:"EventDurationWithMinimumDurationViewController", bundle: Bundle(identifier:"com.andris.ActionsKit"))!
        }
        
        ruleViewController!.rulePresenter = self
        
        return ruleViewController!
    }
    
}
