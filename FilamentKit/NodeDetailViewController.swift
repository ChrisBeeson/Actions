//
//  NodeDetailViewController.swift
//  Filament
//
//  Created by Chris on 12/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class NodeDetailViewController : NSViewController, NodePresenterDelegate, RuleTokenFieldDelegate {
    
    @IBOutlet weak var tokenField: RuleTokenField!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var notesTextField: NSTextField!
    @IBOutlet weak var dateTextField: NSTextField!
    
    // StackView Views
    @IBOutlet weak var mainStackView: NSStackView!
    @IBOutlet weak var titleStackView: NSStackView!
    @IBOutlet weak var eventStackView: NSStackView!

    @IBOutlet weak var rulesTitleStackView: NSStackView!
    @IBOutlet weak var addNodeButton: NSButton!
    
    var nodePresenter: NodePresenter?
    
    var addNodePopover: NSPopover?
    
    private var rulePresenters = [RulePresenter]()
    private var currentlyDisplayedRuleDetailController : RuleViewController?
    
    
    override public func viewDidLoad() {
        
        tokenField.nodePresenter = nodePresenter!
        tokenField.ruleDetailDelegate = self
        nodePresenter!.addDelegate(tokenField)
    }
    
    
    override public func viewWillAppear() {
        super.viewWillAppear()
        
        titleTextField.stringValue = nodePresenter!.title
        notesTextField.stringValue = nodePresenter!.notes
        addNodeButton.hidden = nodePresenter!.availableRules().count > 0 ? false : true
        
        
        /*
        
        https://github.com/mattt/FormatterKit
        
        if nodePresenter!.type == NodeType.Action {
            if let date = nodePresenter!.event?.startDate {
                dateTextField.stringValue = date.formattedDateWithStyle(.LongStyle)
            } else {
                dateTextField.stringValue = ""
            }
        } else {
             dateTextField.stringValue = ""
        }
        */
    }
    
    func displayViewForRule(rule:Rule?) {
        
        if rule == nil {
            if currentlyDisplayedRuleDetailController != nil {
                //  mainStackView.removeArrangedSubview(currentlyDisplayedRuleDetailController!.view)
                mainStackView.removeView(currentlyDisplayedRuleDetailController!.view)
                currentlyDisplayedRuleDetailController = nil
            }
            return
        }
        
        var rulePresenter: RulePresenter?
        
        rulePresenter = rulePresenters.filter({$0.rule == rule}).first
        
        if rulePresenter == nil {
            rulePresenter = RulePresenter.rulePresenterForRule(rule!)
            rulePresenters.append(rulePresenter!)
        }
        
        let viewController = rulePresenter!.detailViewController()
        
        if currentlyDisplayedRuleDetailController == nil {
            currentlyDisplayedRuleDetailController = viewController
            mainStackView.addArrangedSubview(currentlyDisplayedRuleDetailController!.view)
        } else {
            
            if viewController != currentlyDisplayedRuleDetailController {
            mainStackView.removeArrangedSubview(currentlyDisplayedRuleDetailController!.view)
            mainStackView.addArrangedSubview(viewController.view)
             currentlyDisplayedRuleDetailController = viewController
            } else {
                Swift.print("It's the same view controller so doing nothing")
            }
        }
    }
    
    
    @IBAction func titleTextFieldDidFinishEditing(sender: AnyObject) {
        
        nodePresenter!.title = titleTextField.stringValue
    }
    
    

    
    //MARK: RuleTokenField Delegate 
    
    public func ruleTokenFieldDidSelectObjects(tokenField:RuleTokenField, rules:[AnyObject]?) {
      /*
        if let rules = rules {
        
        let rule = rules[0] as! Rule
        displayViewForRule(rule)
        } else {
               displayViewForRule(nil)
        }
*/
    }
    
    @IBAction func addNodeButtonPressed(sender: AnyObject) {
        
        if addNodePopover == nil {
            
            addNodePopover = NSPopover()
            addNodePopover!.animates = true
            addNodePopover!.behavior = .Transient
            addNodePopover!.appearance = NSAppearance(named: NSAppearanceNameAqua)
        }
        
        let viewController = AvailableRulesViewController(nibName:"AvailableRulesViewController", bundle:NSBundle(identifier:"com.andris.FilamentKit"))
        
        viewController!.nodePresenter = nodePresenter
        addNodePopover?.contentViewController = viewController
        addNodePopover?.showRelativeToRect(addNodeButton.frame, ofView: rulesTitleStackView, preferredEdge:.MaxX )

    }
}