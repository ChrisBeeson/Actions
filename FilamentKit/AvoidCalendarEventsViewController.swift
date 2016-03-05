//
//  AvoidCalendarViewController.swift
//  Filament
//
//  Created by Chris Beeson on 5/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class AvoidCalendarEventsViewController : NSViewController {

    @IBOutlet weak var vertStackView: NSStackView!
    
    var rulePresenter: RulePresenter?
    
    override func viewWillLayout() {
        super.viewWillLayout()
        
        guard rulePresenter != nil else { return }
        
        
        // Build the stack view.  Use tags on the checkbox to inform the presenter of any changes.
        
        // for calendar
    }
    
    
}
