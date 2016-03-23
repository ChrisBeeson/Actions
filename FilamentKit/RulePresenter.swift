//
//  RulePresenter.swift
//  Filament
//
//  Created by Chris Beeson on 22/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import AppKit

public enum RuleState : Int {
    
    case Active = 1
    case Inactive
    case Error
}

public class RulePresenter : NSObject {
    
    private var delegates = [RulePresenterDelegate]()
    var undoManager: NSUndoManager?
    public weak var sequencePresenter: SequencePresenter?
    var ruleViewController : RuleViewController?
    
    var rule : Rule
    
    var name : NSString {
        return rule.name
    }
    
    var availableToNodeType : NodeType {
        return rule.availableToNodeType
    }
    
    var editable: Bool {
        return sequencePresenter?.currentState != .Completed
    }
    
    var currentState: RuleState {
        if sequencePresenter == nil { return .Active }
        if sequencePresenter!.currentState == .Completed { return .Inactive }
        return .Active
    }
    
    //MARK: Inits
    
    
    init(rule: Rule) {
        self.rule = rule
        super.init()
    }
    
    init(draggingItem: NSPasteboardItem) {
        
        if let data = draggingItem.dataForType(AppConfiguration.UTI.rule) {
            self.rule = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Rule
        } else {
            fatalError("DraggingItem didn't contain Rule")
        }
        super.init()
    }
    
    
    //MARK: Pasteboard
    
    func draggingItem() -> NSPasteboardItem {
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(self.rule)
        let item = NSPasteboardItem()
        item.setData(data, forType: AppConfiguration.UTI.rule)
        return item
    }
    
    
    //MARK: Factory class
    
    class func rulePresenterForRule(rule: Rule) -> RulePresenter {
        
        switch rule.className {
            
        case "FilamentKit.EventDurationWithMinimumDuration":
            return EventDurationWithMinimumDurationRulePresenter(rule: rule)
            
        case "FilamentKit.TransitionDurationWithVariance":
            return TransitionDurationWithVarianceRulePresenter(rule: rule)
            
        case "FilamentKit.AvoidCalendarEventsRule":
            return AvoidCalendarEventsPresenter(rule: rule)
            
        case "FilamentKit.WorkingWeekRule":
            return WorkingWeekRulePresenter(rule: rule)
            
        default:
            return RulePresenter(rule: rule)
        }
    }
    
    
    //MARK: Delegate helpers
    
    public func addDelegate(delegate:RulePresenterDelegate) {
        
        if !delegates.contains({$0 === delegate}) {
            delegates.append(delegate)
        }
    }
    
    public func removeDelegate(delegate:RulePresenterDelegate) {
        
        delegates = delegates.filter { return $0 !== delegate }
    }
    
    func informDelegatesOfChangesToContent() {
        
        delegates.forEach { $0.rulePresenterDidChangeContent(self) }
    }
    
    
    public func detailViewController() -> RuleViewController {
        
        return RuleViewController(nibName:"EmptyRuleViewController", bundle: NSBundle(identifier:"com.andris.FilamentKit"))!
    }
}