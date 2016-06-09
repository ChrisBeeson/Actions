//
//  WaitForUserPresenter.swift
//  Actions
//
//  Created by Chris Beeson on 28/04/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class WaitForUserPresenter : RulePresenter {
    
    var completed : Bool  {
        get {
            //TODO: Allow this to only be changed once it's later than it's scheduled time.
            return (rule as! WaitForUserRule).userContinued
        }
        set {
            (rule as! WaitForUserRule).userContinued = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    
    public override func detailViewController() -> RuleViewController {
        if ruleViewController == nil {
            let bundle = NSBundle(identifier:"com.andris.ActionsKit")
            ruleViewController = WaitForUserRuleViewController(nibName:"WaitForUserRuleViewController", bundle:bundle)!
            ruleViewController!.rulePresenter = self
        }
        return ruleViewController!
    }
}