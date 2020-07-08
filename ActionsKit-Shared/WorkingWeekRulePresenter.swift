//
//  WorkingWeekRulePresenter.swift
//  Actions
//
//  Created by Chris Beeson on 19/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

open class WorkingWeekRulePresenter : RulePresenter {
    
    open override func detailViewController() -> RuleViewController {
        
        if ruleViewController == nil {
            let bundle = Bundle(identifier:"com.andris.ActionsKit")
            ruleViewController = WorkingWeekViewController(nibName:"WorkingWeekViewController", bundle:bundle)!
            ruleViewController!.rulePresenter = self
        }
        return ruleViewController!
    }
    
    
    var workingDayStartTime: Date {
        get {
            return (rule as! WorkingWeekRule).workingDayStartTime as! Date
        }
        
        set {
          (rule as! WorkingWeekRule).workingDayStartTime = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
        }
    }
    
    
    var workingDayEndTime: Date {
        get {
            return (rule as! WorkingWeekRule).workingDayEndTime as! Date
        }
        
        set {
            (rule as! WorkingWeekRule).workingDayEndTime = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
        }
    }
    
    var workingDayEnabled: Bool {
        get {
            return (rule as! WorkingWeekRule).workingDayEnabled
        }
        
        set {
            (rule as! WorkingWeekRule).workingDayEnabled = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
        }
    }
    
    
    var lunchBreakStartTime: Date {
        get {
            return (rule as! WorkingWeekRule).lunchBreakStartTime as! Date
        }
        
        set {
            (rule as! WorkingWeekRule).lunchBreakStartTime = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
        }
    }
    
    var  lunchBreakEndTime: Date {
        get {
            return (rule as! WorkingWeekRule).lunchBreakEndTime as! Date
        }
        
        set {
            (rule as! WorkingWeekRule).lunchBreakEndTime = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
        }
    }
    
    var  lunchBreakEnabled: Bool {
        get {
            return (rule as! WorkingWeekRule).lunchBreakEnabled
        }
        
        set {
            (rule as! WorkingWeekRule).lunchBreakEnabled = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
        }
    }

    func dayEnabled(_ day: Int) -> Bool {
        if day > 0 && day < 8 {
        return (rule as! WorkingWeekRule).enabledDays[day]!
        } else { print("illegal weekday number"); return false}
    }
    
    func setDayEnabled(_ day: Int, enabled: Bool) {
        
        if day > 0 && day < 8 {
            (rule as! WorkingWeekRule).enabledDays[day] = enabled
            sequencePresenter?.representingDocument?.updateChangeCount(.changeDone)
        } else { print("illegal weekday number")}
    }
}
