//
//  WaitForUserRuleViewController.swift
//  Actions
//
//  Created by Chris on 28/04/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class WaitForUserRuleViewController : RuleViewController {
    
    @IBOutlet weak var continueButton: NSButton!
    
    @IBAction func ContinueButtonChangedState(sender: AnyObject) {
        
        let presenter = self.rulePresenter as! WaitForUserPresenter
        presenter.completed = continueButton.state == NSOnState ? true : false
    }
    
}