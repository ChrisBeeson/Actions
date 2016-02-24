//
//  EventDurationRulePresenter.swift
//  Filament
//
//  Created by Chris Beeson on 22/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class EventDurationRulePresenter : RulePresenter {
    
    public override func detailViewController() -> RuleViewController {
        
        if ruleViewController == nil {
            ruleViewController = EventDurationViewController(nibName:"EventDurationViewController", bundle: NSBundle(identifier:"com.andris.FilamentKit"))!
        }
        
        ruleViewController!.rulePresenter = self
        
        return ruleViewController!
    }
}
