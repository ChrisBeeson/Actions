//
//  ContextPresenter.swift
//  Filament
//
//  Created by Chris Beeson on 4/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class ContextPresenter : NodePresenter {
    
    var filePath: NSURL
    private var context: Context?
    
    init(filePath: NSURL) {
        
        self.filePath = filePath
        
        super.init()
        
        let filemgr = NSFileManager.defaultManager()
        if filemgr.fileExistsAtPath(filePath.path!) {
            self.context = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath.path!) as? Context
        } else {
            self.context = Context()
            let avoidCals = AvoidCalendarEventsRule()
            context?.genericRules.append(avoidCals)
        }
    }
    
    
    override var rules:[Rule] {
        get {
            if let con = context {
                return con.genericRules
            } else {
                return [Rule]()
            }
        }
    }
    

    
    public func save() {
        
       NSKeyedArchiver.archiveRootObject(self.context!, toFile: self.filePath.path!)
    }
   
    
    public func genericRulePresenters() -> [RulePresenter] {
        
        guard context != nil else { print("context is Nil"); return [RulePresenter]() }
        
        return context!.genericRules.map{ RulePresenter(rule: $0) }
    }
    
    
    public func addGenericRulePresenter(rule:RulePresenter, atIndex:Int) {
        
        guard context != nil else { return }
        guard atIndex > -1 && atIndex <= context!.genericRules.count else { return }
        
        context?.genericRules.insert(rule.rule, atIndex: atIndex)
        save()
    }
    
    public func removeRulePresenter(rule:RulePresenter) {
        context?.genericRules.removeObject(rule.rule)
        save()
    }
}
