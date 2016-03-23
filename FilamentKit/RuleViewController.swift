//
//  RuleViewController.swift
//  Filament
//
//  Created by Chris Beeson on 22/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import AppKit

public class RuleViewController : NSViewController, NSMenuDelegate {
    
    public var rulePresenter: RulePresenter?
    
    public override func viewWillDisappear() {
        updateSequence()
         super.viewWillDisappear()
    }
    
    func updateSequence() {
        if let seqPresenter = rulePresenter?.sequencePresenter {
            seqPresenter.updateState()
        } else {
            // It's a generic rule so need to update all sequences
            NSNotificationCenter.defaultCenter().postNotificationName("UpdateAllSequences", object: nil)
        }
    }
    
}