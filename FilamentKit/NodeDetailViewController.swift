//
//  NodeDetailViewController.swift
//  Filament
//
//  Created by Chris on 12/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class NodeDetailViewController : NSViewController, NodePresenterDelegate, RuleCollectionViewDelegate, NSPopoverDelegate {
    
    @IBOutlet weak var ruleCollectionView: RuleCollectionView!

    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var notesTextField: NSTextField!
    @IBOutlet weak var dateTextField: NSTextField!
    
    // StackView Views
    @IBOutlet weak var mainStackView: NSStackView!
    @IBOutlet weak var titleStackView: NSStackView!
    @IBOutlet weak var eventStackView: NSStackView!
    
    @IBOutlet weak var ruleStackView: NSStackView!
    @IBOutlet weak var rulesTitleStackView: NSStackView!
    @IBOutlet weak var addRuleButton: NSButton!
    
    private var popoverVisible = false
    
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
    }
    
    
    override public func viewWillLayout() {
        super.viewWillLayout()
        titleTextField.stringValue = nodePresenter!.title
        notesTextField.stringValue = nodePresenter!.notes
        reloadRulesCollectionView()
    }
    
    override public func viewWillAppear() {
        super.viewWillAppear()
        
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

    @IBAction func titleTextFieldDidFinishEditing(sender: AnyObject) {
        
        nodePresenter!.title = titleTextField.stringValue
    }
    
    
    @IBAction func addRuleButtonPressed(sender: AnyObject) {
        
        guard popoverVisible == false else { return }
        
        let popover = NSPopover()
        popover.animates = true
        popover.behavior = .Transient
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        popover.delegate = self
        
        if availableRulesViewController == nil {
            availableRulesViewController  = AvailableRulesViewController(nibName:"AvailableRulesViewController", bundle:NSBundle(identifier:"com.andris.FilamentKit"))
        }
        availableRulesViewController!.availableRules = nodePresenter
        availableRulesViewController!.collectionViewDelegate = self
        availableRulesViewController!.displayRulesForNodeType = nodePresenter!.type
        popover.contentViewController = availableRulesViewController
       
        //TODO: Select between preferred Edges..
        
        popover.showRelativeToRect(addRuleButton.frame, ofView: rulesTitleStackView, preferredEdge:.MinX )
        // popover.showRelativeToRect(ruleCollectionView.bounds, ofView: ruleStackView, preferredEdge:.MaxY )
    }
    
    
    func reloadRulesCollectionView() {
        
        ruleCollectionView.rulePresenters = nodePresenter!.currentRulePresenters()
        ruleCollectionView.reloadData()
        availableRulesViewController?.reloadCollectionView()
        // addNodeButton.hidden = nodePresenter!.availableRules().count > 0 ? false : true
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
    }
    
    
    // MARK: NodePresenter Delegate Calls
    
    func nodePresenterDidChangeRules(presenter: NodePresenter) {
        
        // let diff = presenter.allRulePresenters().diff(rulePresenters)  // get the diff if I want to animate these things later...
        //  ruleCollectionView.animator().insertItemsAtIndexPaths([NSIndexPath(forItem: atIndex, inSection: 0)]) <- bug
        
        reloadRulesCollectionView()
    }
    
    // MARK: Popover delegate
    
    public func popoverWillShow(notification: NSNotification) {
        popoverVisible = true
    }
    
    public func popoverDidClose(notification: NSNotification) {
         popoverVisible = false
    }
    
}