//
//  RuleViewController.swift
//  Actions
//
//  Created by Chris Beeson on 22/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import AppKit

open class RuleViewController : NSViewController, NSMenuDelegate {
    
    open var rulePresenter: RulePresenter?
    
    open override func viewWillDisappear() {
        updateSequence()
         super.viewWillDisappear()
    }
    
    func updateSequence() {
        if let seqPresenter = rulePresenter?.sequencePresenter {
            seqPresenter.updateState(processEvents: true)
        } else {
            // It's a generic rule so need to update all sequences
            NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateAllSequences"), object: nil)
        }
    }
    
}
