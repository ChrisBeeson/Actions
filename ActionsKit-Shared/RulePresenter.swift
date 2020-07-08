//
//  RulePresenter.swift
//  Actions
//
//  Created by Chris Beeson on 22/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//
import Foundation
import AppKit

public enum RuleState : Int {
    case active = 1
    case inactive
    case error
}

open class RulePresenter : NSObject {
    
    fileprivate var delegates = [RulePresenterDelegate]()
    var undoManager: UndoManager?
    open weak var sequencePresenter: SequencePresenter?
    var ruleViewController : RuleViewController?
    var rule : Rule
    
    var useDetailName = true
    
    var name : NSString {
        if useDetailName == true {return rule.detailName as NSString }
        else {return rule.name as NSString }
    }
    
    var availableToNodeType : NodeType {
        return rule.availableToNodeType
    }
    
    var editable: Bool {
        return sequencePresenter?.currentState != .completed
    }
    
    var currentState: RuleState {
        if sequencePresenter == nil { return .active }
        if sequencePresenter!.currentState == .completed { return .inactive }
        return .active
    }

    
    //MARK: Inits

    init(rule: Rule) {
        self.rule = rule
        super.init()
    }
    
    init(pasteboardItem: NSPasteboardItem) {
        if let data = pasteboardItem.data(forType: AppConfiguration.UTI.rule) {
            self.rule = NSKeyedUnarchiver.unarchiveObject(with: data) as! Rule
        } else {
            fatalError("PasteboardItem didn't contain Rule")
        }
        super.init()
    }
    
    
    //MARK: Pasteboard
    
    func pasteboardItem() -> NSPasteboardItem {
        let data = NSKeyedArchiver.archivedData(withRootObject: self.rule)
        let item = NSPasteboardItem()
        item.setData(data, forType: AppConfiguration.UTI.rule)
        return item
    }
    
    
    //MARK: Factory
    
    class func makeRulePresenter(_ rule: Rule) -> RulePresenter {
        
        switch rule.className {
        case TransitionDurationWithVariance.className():        return TransitionDurationWithVarianceRulePresenter(rule: rule)
        case EventDurationWithMinimumDuration.className():      return EventDurationWithMinimumDurationRulePresenter(rule: rule)
        case AvoidCalendarEventsRule.className():               return AvoidCalendarEventsPresenter(rule: rule)
        case WorkingWeekRule.className():                       return WorkingWeekRulePresenter(rule: rule)
        case GreaterThanLessThanRule.className():               return GreaterThanLessThanRulePresenter(rule: rule)
        case NextUnitRule.className():                          return NextUnitRulePresenter(rule: rule)
        case WaitForUserRule.className():                       return WaitForUserPresenter(rule: rule)
        case EventAlarmRule.className():                        return EventAlarmRulePresenter(rule: rule)
      //case TransitionDurationBasedOnTravelTime.className():   return TransitionDurationBasedOnTravelTime(map)
     // case EventFixedStartAndEndDate.className():             return EventFixedStartAndEndDate(map)
        default:                                                return RulePresenter(rule: rule)
        }
    }
    
    
    //MARK: Delegate helpers
    
    open func addDelegate(_ delegate:RulePresenterDelegate) {
        if !delegates.contains(where: {$0 === delegate}) {
            delegates.append(delegate)
        }
    }
    
    open func removeDelegate(_ delegate:RulePresenterDelegate) {
        delegates = delegates.filter { return $0 !== delegate }
    }
    
    func informDelegatesOfChangesToContent() {
        delegates.forEach { $0.rulePresenterDidChangeContent(self) }
    }
    
    //MARK: Detail View Controller
    
    open func detailViewController() -> RuleViewController {
        return RuleViewController(nibName:"EmptyRuleViewController", bundle: Bundle(identifier:"com.andris.ActionsKit"))!
    }
}
