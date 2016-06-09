//
//  EventAlarmRuleViewController.swift
//  Actions
//
//  Created by Chris on 20/04/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import AppKit

class EventAlarmRuleViewController : RuleViewController {
    
    @IBOutlet weak var mainStackView: NSStackView!
    @IBOutlet weak var amountUnitStackView: NSStackView!
    
    @IBOutlet weak var amountTextField: NSTextField!
    @IBOutlet weak var emailAddressField: NSTextField!
    
    @IBAction func alarmTypePopUpChanged(sender: AnyObject) {
    layoutStackViews()
    }
    
    @IBAction func alarmUnitPopUpDidChange(sender: AnyObject) {
        layoutStackViews()
    }
    
    func layoutStackViews() {
        let presenter = self.rulePresenter as! EventAlarmRulePresenter
        emailAddressField.hidden = AlarmType(rawValue: presenter.alarmType) == AlarmType.Email ? false : true
        amountTextField.hidden = AlarmOffset(rawValue: presenter.alarmOffsetUnit) == AlarmOffset.OnDate ? true : false
    }
    
    override func viewWillAppear() {
        layoutStackViews()
    }
}
