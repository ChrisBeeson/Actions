//
//  WaitForUserPresenter.swift
//  Actions
//
//  Created by Chris Beeson on 28/04/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

//
//  NextUnitRulePresenter.swift
//  Actions
//
//  Created by Chris Beeson on 24/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class WaitForUserPresenter : RulePresenter {
    
    var completed : Bool  {
        get {
            return (rule as! WaitForUserRule).completed
        }
        set {
            (rule as! WaitForUserRule).completed = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    /*
    public override func detailViewController() -> RuleViewController {
        if ruleViewController == nil {
            let bundle = NSBundle(identifier:"com.andris.ActionsKit")
            ruleViewController = GreaterThanLessThanRuleViewController(nibName:"NextUnitRuleViewController", bundle:bundle)!
            ruleViewController!.rulePresenter = self
        }
        return ruleViewController!
    }
 */
}
