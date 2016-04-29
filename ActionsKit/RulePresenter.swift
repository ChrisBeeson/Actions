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
    
    var useDetailName = true
    
    var name : NSString {
        if useDetailName == true {return rule.detailName }
        else {return rule.name }
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
    
    init(pasteboardItem: NSPasteboardItem) {
        if let data = pasteboardItem.dataForType(AppConfiguration.UTI.rule) {
            self.rule = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Rule
        } else {
            fatalError("PasteboardItem didn't contain Rule")
        }
        super.init()
    }
    
    
    //MARK: Pasteboard
    
    func pasteboardItem() -> NSPasteboardItem {
        let data = NSKeyedArchiver.archivedDataWithRootObject(self.rule)
        let item = NSPasteboardItem()
        item.setData(data, forType: AppConfiguration.UTI.rule)
        return item
    }
    
    
    //MARK: Factory
    
    class func makeRulePresenter(rule: Rule) -> RulePresenter {
        
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
    
    //MARK: Detail View Controller
    
    public func detailViewController() -> RuleViewController {
        return RuleViewController(nibName:"EmptyRuleViewController", bundle: NSBundle(identifier:"com.andris.ActionsKit"))!
    }
}