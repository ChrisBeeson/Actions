//
//  EventAlarmRulePresenter.swift
//  Actions
//
//  Created by Chris on 20/04/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class EventAlarmRulePresenter : RulePresenter {
    
    var alarmType : Int {
        get {
            return (rule as! EventAlarmRule).alarmType.rawValue
        }
        set {
            (rule as! EventAlarmRule).alarmType = AlarmType(rawValue: newValue)!
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    var alarmOffsetUnit : Int  {
        get {
            return (rule as! EventAlarmRule).alarmOffsetUnit.rawValue
        }
        set {
            let value = newValue < 0 ? 0 : newValue
            
            if let offset = AlarmOffset(rawValue:value) {
                (rule as! EventAlarmRule).alarmOffsetUnit = offset
                sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
                informDelegatesOfChangesToContent()
            }
        }
    }
    
    var offsetAmount : Int {
        get {
            return (rule as! EventAlarmRule).offsetAmount
        }
        set {
            (rule as! EventAlarmRule).offsetAmount = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    var emailAddress : String {
        get {
            return (rule as! EventAlarmRule).emailAddress
        }
        set {
            (rule as! EventAlarmRule).emailAddress = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
            informDelegatesOfChangesToContent()
        }
    }
    
    public override func detailViewController() -> RuleViewController {
        if ruleViewController == nil {
            let bundle = NSBundle(identifier:"com.andris.ActionsKit")
            ruleViewController = EventAlarmRuleViewController(nibName:"EventAlarmRuleViewController", bundle:bundle)!
            ruleViewController!.rulePresenter = self
        }
        return ruleViewController!
    }
}