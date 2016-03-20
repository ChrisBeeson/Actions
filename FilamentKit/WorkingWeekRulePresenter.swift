//
//  WorkingWeekRulePresenter.swift
//  Filament
//
//  Created by Chris Beeson on 19/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class WorkingWeekRulePresenter : RulePresenter {
    
    public override func detailViewController() -> RuleViewController {
        
        if ruleViewController == nil {
            let bundle = NSBundle(identifier:"com.andris.FilamentKit")
            ruleViewController = WorkingWeekViewController(nibName:"WorkingWeekViewController", bundle:bundle)!
            ruleViewController!.rulePresenter = self
        }
        return ruleViewController!
    }
    
    
    var workingDayStartTime: NSDate {
        get {
            return (rule as! WorkingWeekRule).workingDayStartTime
        }
        
        set {
          (rule as! WorkingWeekRule).workingDayStartTime = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
        }
    }
    
    
    var workingDayEndTime: NSDate {
        get {
            return (rule as! WorkingWeekRule).workingDayEndTime
        }
        
        set {
            (rule as! WorkingWeekRule).workingDayEndTime = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
        }
    }
    
    var workingDayEnabled: Bool {
        get {
            return (rule as! WorkingWeekRule).workingDayEnabled
        }
        
        set {
            (rule as! WorkingWeekRule).workingDayEnabled = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
        }
    }
    
    
    var lunchBreakStartTime: NSDate {
        get {
            return (rule as! WorkingWeekRule).lunchBreakStartTime
        }
        
        set {
            (rule as! WorkingWeekRule).lunchBreakStartTime = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
        }
    }
    
    var  lunchBreakEndTime: NSDate {
        get {
            return (rule as! WorkingWeekRule).lunchBreakEndTime
        }
        
        set {
            (rule as! WorkingWeekRule).lunchBreakEndTime = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
        }
    }
    
    var  lunchBreakEnabled: Bool {
        get {
            return (rule as! WorkingWeekRule).lunchBreakEnabled
        }
        
        set {
            (rule as! WorkingWeekRule).lunchBreakEnabled = newValue
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
        }
    }

    func dayEnabled(day: Int) -> Bool {
        if day > 0 && day < 8 {
        return (rule as! WorkingWeekRule).enabledDays[day]!
        } else { print("illegal weekday number"); return false}
    }
    
    func setDayEnabled(day: Int, enabled: Bool) {
        
        if day > 0 && day < 8 {
            (rule as! WorkingWeekRule).enabledDays[day] = enabled
            sequencePresenter?.representingDocument?.updateChangeCount(.ChangeDone)
        } else { print("illegal weekday number")}
    }
}