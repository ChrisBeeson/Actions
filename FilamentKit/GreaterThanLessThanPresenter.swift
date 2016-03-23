//
//  GreaterLessThanPresenter.swift
//  Filament
//
//  Created by Chris Beeson on 23/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

public class GreaterThanLessThanRulePresenter : RulePresenter {
    
    var greaterThan : Int  {
        get {
            return (rule as! GreaterThanLessThanRule).greaterThan.amount
        }
        set {
            (rule as! GreaterThanLessThanRule).greaterThan.amount = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    var greaterThanUnit : UInt {
        get {
            return (rule as! GreaterThanLessThanRule).greaterThan.unit.rawValue
        }
        set {
            (rule as! GreaterThanLessThanRule).greaterThan.unit = DTTimePeriodSize(rawValue: newValue)!
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
            informDelegatesOfChangesToContent()
        }
    }

    var lessThan : Int  {
        get {
            return (rule as! GreaterThanLessThanRule).lessThan.amount
        }
        set {
            (rule as! GreaterThanLessThanRule).lessThan.amount = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    var lessThanUnit : UInt {
        get {
            return (rule as! GreaterThanLessThanRule).lessThan.unit.rawValue
        }
        set {
            (rule as! GreaterThanLessThanRule).lessThan.unit = DTTimePeriodSize(rawValue: newValue)!
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
            informDelegatesOfChangesToContent()
        }
    }
    

    public override func detailViewController() -> RuleViewController {
        
        if ruleViewController == nil {
            let bundle = NSBundle(identifier:"com.andris.FilamentKit")
            ruleViewController = GreaterThanLessThanRuleViewController(nibName:"GreaterThanLessThanRuleViewController", bundle:bundle)!
            ruleViewController!.rulePresenter = self
        }
        return ruleViewController!
}
}