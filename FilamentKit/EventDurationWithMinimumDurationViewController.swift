//
//  EventDurationWithMinimumDurationViewController.swift
//  Filament
//
//  Created by Chris Beeson on 26/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class EventDurationWithMinimumDurationViewController : RuleViewController, NSComboBoxDelegate, RulePresenterDelegate  {
    
    @IBOutlet weak var durationUnitComboBox: NSComboBox!
    @IBOutlet weak var minDurationUnitComboBox: NSComboBox!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshComboBoxes()
    }
    
    
    func refreshComboBoxes() {
     
        let presenter = rulePresenter as! EventDurationWithMinimumDurationRulePresenter
        
        durationUnitComboBox.selectItemAtIndex(Int(presenter.durationUnit))
        durationUnitComboBox.stringValue = durationUnitComboBox.objectValueOfSelectedItem as! String
        
        minDurationUnitComboBox.selectItemAtIndex(Int(presenter.minDurationUnit))
        minDurationUnitComboBox.stringValue = minDurationUnitComboBox.objectValueOfSelectedItem as! String
    }
    
    
    func comboBoxSelectionDidChange(notification: NSNotification) {
        
        let combobox = notification.object as! NSComboBox
        let presenter = rulePresenter as! EventDurationWithMinimumDurationRulePresenter
        
        switch combobox.tag {
            
        case 1:
            presenter.durationUnit = UInt(combobox.indexOfSelectedItem)
            
        case 2:
            presenter.minDurationUnit = UInt(combobox.indexOfSelectedItem)
            
        default: break
        }
    }
    
    func rulePresenterDidChangeContent(presenter: RulePresenter) {
        
        refreshComboBoxes()
    }
}
