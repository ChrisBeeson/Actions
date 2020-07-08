//
//  GreaterLessThanPresenter.swift
//  Actions
//
//  Created by Chris Beeson on 23/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

open class GreaterThanLessThanRulePresenter : RulePresenter {
    
    var greaterThan : Int  {
        get {
            return (rule as! GreaterThanLessThanRule).greaterThan.amount
        }
        set {
            (rule as! GreaterThanLessThanRule).greaterThan.amount = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    var greaterThanUnit : UInt {
        get {
            return (rule as! GreaterThanLessThanRule).greaterThan.unit.rawValue
        }
        set {
            (rule as! GreaterThanLessThanRule).greaterThan.unit = DTTimePeriodSize(rawValue: newValue)!
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
            informDelegatesOfChangesToContent()
        }
    }

    var lessThan : Int  {
        get {
            return (rule as! GreaterThanLessThanRule).lessThan.amount
        }
        set {
            (rule as! GreaterThanLessThanRule).lessThan.amount = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    var lessThanUnit : UInt {
        get {
            return (rule as! GreaterThanLessThanRule).lessThan.unit.rawValue
        }
        set {
            (rule as! GreaterThanLessThanRule).lessThan.unit = DTTimePeriodSize(rawValue: newValue)!
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    open override func detailViewController() -> RuleViewController {
        
        if ruleViewController == nil {
            let bundle = Bundle(identifier:"com.andris.ActionsKit")
            ruleViewController = GreaterThanLessThanRuleViewController(nibName:"GreaterThanLessThanRuleViewController", bundle:bundle)!
            ruleViewController!.rulePresenter = self
        }
        return ruleViewController!
}
}
