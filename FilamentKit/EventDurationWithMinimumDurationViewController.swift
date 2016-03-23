//
//  EventDurationWithMinimumDurationViewController.swift
//  Filament
//
//  Created by Chris Beeson on 26/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import AppKit

class EventDurationWithMinimumDurationViewController : RuleViewController, RulePresenterDelegate  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
    }
}
