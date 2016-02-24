//
//  EventDurationRulePresenter.swift
//  Filament
//
//  Created by Chris Beeson on 22/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class TransitionDurationWithVarianceRulePresenter : RulePresenter {
    
    var duration : Int  {
        get {
            
            Swift.print( (rule as! TransitionDurationWithVariance).eventStartsInDuration.amount)
            
            return (rule as! TransitionDurationWithVariance).eventStartsInDuration.amount
        }
    }
    
    public override func detailViewController() -> RuleViewController {
        
        if ruleViewController == nil {
            ruleViewController = DurationWithVarianceViewController(nibName:"DurationWithVarianceViewController", bundle: NSBundle(identifier:"com.andris.FilamentKit"))!
        }
        
        ruleViewController!.rulePresenter = self
        
        return ruleViewController!
    }
}
