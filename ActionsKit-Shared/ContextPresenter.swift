//
//  ContextPresenter.swift
//  Actions
//
//  Created by Chris Beeson on 4/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

open class ContextPresenter : NodePresenter {
    
    var filePath: URL
    fileprivate var context: Context?
    
    init(filePath: URL) {
        
        self.filePath = filePath
        
        super.init()
        
        let filemgr = FileManager.default
        if filemgr.fileExists(atPath: filePath.path) {
            self.context = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.path) as? Context
        } else {
            self.context = Context()
            let avoidCals = AvoidCalendarEventsRule()
            context?.genericRules.append(avoidCals)
        }
    }
    
    
    override open var rules:[Rule] {
        get {
            if let con = context {
                return con.genericRules
            } else {
                return [Rule]()
            }
        }
    }
    
    override open var type: NodeType { get { return [.Generic] }  set {}}
    

    open func save() {
        
       NSKeyedArchiver.archiveRootObject(self.context!, toFile: self.filePath.path)
    }
   
    
    open func addRulePresenter(_ rule:RulePresenter, atIndex:Int) {
        
        guard context != nil else { return }
        guard atIndex > -1 && atIndex <= context!.genericRules.count else { return }
        
        context?.genericRules.insert(rule.rule, at: atIndex)
        save()
    }
    
    open func removeRulePresenter(_ rule:RulePresenter) {
        context?.genericRules.removeObject(rule.rule)
        save()
    }
}
