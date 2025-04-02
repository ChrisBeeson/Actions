//
//  NextUnitRulePresenter.swift
//  Actions
//
//  Created by Chris Beeson on 24/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

open class NextUnitRulePresenter : RulePresenter {
    
    var amount : Int  {
        get {
            return (rule as! NextUnitRule).amount
        }
        set {
            let value = newValue < 0 ? 0 : newValue
            (rule as! NextUnitRule).amount = value
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    var unit : Int {
        get {
            return (rule as! NextUnitRule).unit.rawValue
        }
        set {
            (rule as! NextUnitRule).unit = NextUnitType(rawValue: newValue)!
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
            informDelegatesOfChangesToContent()
        }
}
    
    var preferedTime : Int {
        get {
            return (rule as! NextUnitRule).preferedTime.rawValue
        }
        set {
            (rule as! NextUnitRule).preferedTime = NextPreferedTimeType(rawValue: newValue)!
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    open override func detailViewController() -> RuleViewController {
        if ruleViewController == nil {
            let bundle = Bundle(identifier:"com.andris.ActionsKit")
            ruleViewController = GreaterThanLessThanRuleViewController(nibName:"NextUnitRuleViewController", bundle:bundle)!
            ruleViewController!.rulePresenter = self
        }
        return ruleViewController!
    }
}
