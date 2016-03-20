//
//  WorkingWeekViewController.swift
//  Filament
//
//  Created by Chris Beeson on 19/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class WorkingWeekViewController : RuleViewController {
    
    @IBOutlet weak var daysStackView: NSStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDayButtons()
    }
    
    func updateDayButtons(){
        
        for subview in daysStackView.subviews {
            if subview.isKindOfClass(NSButton) {
                let state = (rulePresenter as! WorkingWeekRulePresenter).dayEnabled(subview.tag)
                (subview as! NSButton).state = state == true ? NSOnState : NSOffState
            }
        }
    }
    
    @IBAction func buttonChangeState(sender: AnyObject) {
        
        let tag = (sender as! NSButton).tag
        let state = (sender as! NSButton).state == NSOnState ? true : false
        (rulePresenter as! WorkingWeekRulePresenter).setDayEnabled(tag, enabled: state)
    }
    
}
