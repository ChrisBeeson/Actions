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

    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // create rulePresenters for each of the rules
        rulePresenters = nodePresenter!.rules.map { RulePresenter.rulePresenterForRule($0) }
        ruleCollectionView.ruleCollectionViewDelegate = self
        ruleCollectionView.rules = rulePresenters
        ruleCollectionView.allowDrops = true
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
    
    
    
    //MARK: Delegates
    
    public func didAcceptDrop(collectionView: RuleCollectionView, droppedRulePresenter: RulePresenter, atIndex: Int) {
        
        Swift.print(atIndex)
        
        rulePresenters.insert(droppedRulePresenter, atIndex: atIndex)
        ruleCollectionView.rules = rulePresenters
        ruleCollectionView.reloadData()
        //  ruleCollectionView.animator().insertItemsAtIndexPaths([NSIndexPath(forItem: atIndex, inSection: 0)])
    }
}