//
//  NodeDetailViewController.swift
//  Filament
//
//  Created by Chris on 12/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class NodeDetailViewController : NSViewController, NodePresenterDelegate, RuleCollectionViewDelegate {
    
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
    private var rulePresenters = [RulePresenter]()

    var availableNodesViewController: AvailableRulesViewController?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        nodePresenter?.addDelegate(self)
        ruleCollectionView.ruleCollectionViewDelegate = self
        ruleCollectionView.rules = rulePresenters
        ruleCollectionView.allowDrops = true
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
    
    
    @IBAction func addNodeButtonPressed(sender: AnyObject) {
        
        let popover = NSPopover()
        popover.animates = true
        popover.behavior = .Transient
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        
        if availableNodesViewController == nil {
            availableNodesViewController  = AvailableRulesViewController(nibName:"AvailableRulesViewController", bundle:NSBundle(identifier:"com.andris.FilamentKit"))
        }
        availableNodesViewController!.nodePresenter = nodePresenter
        popover.contentViewController = availableNodesViewController
        popover.showRelativeToRect(addNodeButton.frame, ofView: rulesTitleStackView, preferredEdge:.MaxX )
        //  popover.showRelativeToRect(ruleCollectionView.frame, ofView: ruleCollectionView, preferredEdge:.MinY )
    }
    
    
    func reloadRulesCollectionView() {
        
        rulePresenters = nodePresenter!.rules.map { RulePresenter.rulePresenterForRule($0) }
        ruleCollectionView.rules = rulePresenters
        ruleCollectionView.reloadData()
        availableNodesViewController?.reloadCollectionView()
        // addNodeButton.hidden = nodePresenter!.availableRules().count > 0 ? false : true
    }
    
    
    //MARK: RuleCollectionView Delegates
    
    public func didAcceptDrop(collectionView: RuleCollectionView, droppedRulePresenter: RulePresenter, atIndex: Int) {
        
        nodePresenter?.insertRulePresenter(droppedRulePresenter, atIndex:atIndex)
    }
    
    public func didDeleteRulePresenter(collectionView: RuleCollectionView, deletedRulePresenter: RulePresenter) {
        
        nodePresenter?.deleteRulePresenter(deletedRulePresenter)
    }
    
    
    // MARK: NodePresenter Delegate Calls
    
    func nodePresenterDidChangeRules(presenter: NodePresenter) {
        
        // let diff = presenter.allRulePresenters().diff(rulePresenters)  // get the diff if I want to animate these things later...
        //  ruleCollectionView.animator().insertItemsAtIndexPaths([NSIndexPath(forItem: atIndex, inSection: 0)]) <- bug
        
        reloadRulesCollectionView()
    }
}