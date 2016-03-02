//
//  NodeDetailViewController.swift
//  Filament
//
//  Created by Chris on 12/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class NodeDetailViewController : NSViewController, NodePresenterDelegate {
    
    @IBOutlet weak var ruleCollectionView: RuleCollectionView!

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
    
    var popover: NSPopover?
    
    private var rulePresenters = [RulePresenter]()
    private var currentlyDisplayedRuleDetailController : RuleViewController?
    
    
    override public func viewDidLoad() {
        
        // create rulePresenters for each of the rules
        rulePresenters = nodePresenter!.rules.map { RulePresenter.rulePresenterForRule($0) }
        
        Swift.print(rulePresenters)
        ruleCollectionView.rules = rulePresenters
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
    
    
    
    @IBAction func addNodeButtonPressed(sender: AnyObject) {
        
        let popover = NSPopover()
        popover.animates = true
        popover.behavior = .Transient
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        
        let viewController = AvailableRulesViewController(nibName:"AvailableRulesViewController", bundle:NSBundle(identifier:"com.andris.FilamentKit"))
        
        viewController!.nodePresenter = nodePresenter
        popover.contentViewController = viewController
        popover.showRelativeToRect(addNodeButton.frame, ofView: rulesTitleStackView, preferredEdge:.MaxX )
    }
}