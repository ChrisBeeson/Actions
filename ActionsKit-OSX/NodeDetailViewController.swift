//
//  NodeDetailViewController.swift
//  Actions
//
//  Created by Chris on 12/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import AppKit

public class NodeDetailViewController : NSViewController, NodePresenterDelegate, RuleCollectionViewDelegate, NSPopoverDelegate {
    
    @IBOutlet weak var ruleCollectionView: RuleCollectionView!

    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var notesTextField: NSTextField!
    @IBOutlet weak var dateTextField: NSTextField!
    @IBOutlet weak var locationTextField: NSTextField!
    
    @IBOutlet weak var eventStringStackView: NSStackView!
    
    // StackView Views
    @IBOutlet weak var mainStackView: NSStackView!
    @IBOutlet weak var titleStackView: NSStackView!
    @IBOutlet weak var eventStackView: NSStackView!
    
    @IBOutlet weak var ruleStackView: NSStackView!
    @IBOutlet weak var rulesTitleStackView: NSStackView!
    @IBOutlet weak var addRuleButton: NSButton!
    
    private var displayedPopover:NSPopover?
    
    var nodePresenter: NodePresenter?

    var availableRulesViewController: AvailableRulesViewController?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        guard nodePresenter != nil else { fatalError() }
        
        nodePresenter!.addDelegate(self)
        ruleCollectionView.ruleCollectionViewDelegate = self
        ruleCollectionView.rulePresenters = nodePresenter!.currentRulePresenters()
        ruleCollectionView.allowDrops = true
        ruleCollectionView.allowDropsFromType = nodePresenter!.type
        ruleCollectionView.allowDeletions = true
      /*
        mainStackView.detachesHiddenViews = false
        if nodePresenter!.type == NodeType.Transition {
            eventStringStackView.hidden = true
        }
*/
         reloadRulesCollectionView()
    }
    
    
    override public func viewWillLayout() {
        super.viewWillLayout()
       
    }
    
    override public func viewWillAppear() {
        super.viewWillAppear()
        
        if nodePresenter!.currentState == .Completed {
            titleTextField.editable = false
            locationTextField.editable = false
            ruleCollectionView.allowDrops = false
            ruleCollectionView.allowDeletions = false
            addRuleButton.hidden = true
        }
    }

    @IBAction func titleTextFieldDidFinishEditing(sender: AnyObject) {
    }
    
    
    @IBAction func addRuleButtonPressed(sender: AnyObject) {
        if displayedPopover != nil { return }
        
        let popover = NSPopover()
        popover.animates = true
        popover.behavior = .Transient
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        popover.delegate = self
        
        if availableRulesViewController == nil {
            availableRulesViewController  = AvailableRulesViewController(nibName:"AvailableRulesViewController", bundle:NSBundle(identifier:"com.andris.ActionsKit"))
        }
        availableRulesViewController!.availableRules = nodePresenter
        availableRulesViewController!.collectionViewDelegate = self
        availableRulesViewController!.displayRulesForNodeType = nodePresenter!.type
        popover.contentViewController = availableRulesViewController
        popover.showRelativeToRect(addRuleButton.frame, ofView: rulesTitleStackView, preferredEdge:.MaxX )
    }
    
    
    func reloadRulesCollectionView() {
        ruleCollectionView.rulePresenters = nodePresenter!.currentRulePresenters()
        ruleCollectionView.reloadData()
        availableRulesViewController?.reloadCollectionView()
        //addNodeButton.hidden = nodePresenter!.availableRules().count > 0 ? false : true
    }
    
    
    //MARK: RuleCollectionView Delegates
    
    public func didAcceptDrop(collectionView: RuleCollectionView, droppedRulePresenter: RulePresenter, atIndex: Int) {
        
        nodePresenter?.insertRulePresenter(droppedRulePresenter, atIndex:atIndex)
    }
    
    public func didDeleteRulePresenter(collectionView: RuleCollectionView, deletedRulePresenter: RulePresenter) {
        
        nodePresenter?.deleteRulePresenter(deletedRulePresenter)
    }
    
    public func didDoubleClick(collectionView: RuleCollectionView, selectedRulePresenter: RulePresenter) {
        nodePresenter?.insertRulePresenter(selectedRulePresenter, atIndex:nodePresenter!.rules.count)
        displayedPopover?.close()
    }
    
    
    // MARK: NodePresenter Delegate Calls
    
    func nodePresenterDidChangeRules(presenter: NodePresenter) {
        
        // let diff = presenter.allRulePresenters().diff(rulePresenters)  // get the diff if I want to animate these things later...
        //  ruleCollectionView.animator().insertItemsAtIndexPaths([NSIndexPath(forItem: atIndex, inSection: 0)]) <- bug
        
        reloadRulesCollectionView()
    }
    
    //MARK: NSPopover Delegate
    
    public func popoverWillShow(notification: NSNotification) {
        displayedPopover = notification.object as? NSPopover
    }
    
    public func popoverDidClose(notification: NSNotification) {
        displayedPopover = nil
    }
}