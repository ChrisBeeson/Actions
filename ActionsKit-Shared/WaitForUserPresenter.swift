//
//  WaitForUserPresenter.swift
//  Actions
//
//  Created by Chris Beeson on 28/04/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

open class WaitForUserPresenter : RulePresenter {
    
    var completed : Bool  {
        get {
            //TODO: Allow this to only be changed once it's later than it's scheduled time.
            return (rule as! WaitForUserRule).userContinued
        }
        set {
            (rule as! WaitForUserRule).userContinued = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    
    open override func detailViewController() -> RuleViewController {
        if ruleViewController == nil {
            let bundle = Bundle(identifier:"com.andris.ActionsKit")
            ruleViewController = WaitForUserRuleViewController(nibName:"WaitForUserRuleViewController", bundle:bundle)!
            ruleViewController!.rulePresenter = self
        }
        return ruleViewController!
    }
}
