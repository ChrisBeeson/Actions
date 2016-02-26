//
//  EventDurationViewController.swift
//  Filament
//
//  Created by Chris on 24/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools

class DurationWithVarianceViewController : RuleViewController, NSComboBoxDelegate, RulePresenterDelegate  {
    
    @IBOutlet weak var durationUnitComboBox: NSComboBox!
    @IBOutlet weak var variationUnitComboBox: NSComboBox!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshComboBoxes()
    }
    

    func refreshComboBoxes() {
        
        let presenter = rulePresenter as! TransitionDurationWithVarianceRulePresenter
        
        durationUnitComboBox.selectItemAtIndex(Int(presenter.durationUnit))
        durationUnitComboBox.stringValue = durationUnitComboBox.objectValueOfSelectedItem as! String
        
        variationUnitComboBox.selectItemAtIndex(Int(presenter.varianceUnit))
        variationUnitComboBox.stringValue = variationUnitComboBox.objectValueOfSelectedItem as! String
    }
    
    
    func comboBoxSelectionDidChange(notification: NSNotification) {
        
        let combobox = notification.object as! NSComboBox
        let presenter = rulePresenter as! TransitionDurationWithVarianceRulePresenter
          
            switch combobox.tag {
                
            case 1:
                presenter.durationUnit = UInt(combobox.indexOfSelectedItem)
                
            case 2:
                 presenter.varianceUnit = UInt(combobox.indexOfSelectedItem)
                
            default: break
            }
    }
    
    func rulePresenterDidChangeContent(presenter: RulePresenter) {
        
        refreshComboBoxes()
    }
}
