//
//  SequenceTableRowView.swift
//  Filament
//
//  Created by Chris Beeson on 12/12/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa
import FilamentKit

public class FilamentTableCellView: NSTableCellView, SequencePresenterDelegate, RuleCollectionViewDelegate {
    
    override public var acceptsFirstResponder: Bool { return true }
    
    @IBOutlet weak var backgroundView: NSView!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var sequenceCollectionView: SequenceCollectionView!
    @IBOutlet weak var scrollview: NSScrollView!
    
    @IBOutlet weak var addGenericRuleButton: NSButton!
    @IBOutlet weak var favouriteButton: NSButton!
    @IBOutlet weak var generalRulesCollectionView: RuleCollectionView!
    
    private var availableGeneralRulesViewController : AvailableRulesViewController?
    
    
    public var presenter: SequencePresenter? {
        
        didSet {
            sequenceCollectionView.presenter = presenter
            if presenter != nil {
                presenter!.addDelegate(self)
            }
            updateCellView()
        }
    }
    
    public var selected: Bool {
        didSet {
            switch selected {
            case true:
                backgroundView.layer?.borderWidth = 2
                backgroundView.layer?.borderColor = AppConfiguration.Palette.selectionBlue.CGColor
                titleTextField.editable = true
                
            case false:
                backgroundView.layer?.borderWidth = 0
                titleTextField.editable = false
                sequenceCollectionView.deselectAll(self)
            }
        }
    }
    
    
    // MARK: Methods
    
    required public init?(coder: NSCoder) {
        
        selected = false
        super.init(coder: coder)
        
    }
    
    
    override public func viewWillDraw() {
        super.viewWillDraw()
        generalRulesCollectionView.collectionViewLayout = RightAlignedCollectionViewFlowLayout()
        generalRulesCollectionView.ruleCollectionViewDelegate = self
        generalRulesCollectionView.allowDrops = true
        generalRulesCollectionView.allowDropsFromType = [.Generic]
        generalRulesCollectionView.allowDeletions = true
    }
    
    
    func updateCellView() {
        
        scrollview.horizontalScroller?.alphaValue = 0.0
        backgroundView.backgroundColor = NSColor.whiteColor()
        
        if presenter != nil {
            
            titleTextField.stringValue = presenter!.title
            self.sequenceCollectionView.toolTip = String(presenter!.status)
            sequenceCollectionView.reloadData()
        }
        
        refreshGeneralRulesCollectionView()
    }
    
    
    @IBAction func titleTextFieldDidChange(sender: NSTextField) {
        
        presenter!.renameTitle(sender.stringValue)
    }

    
    @IBAction func addGeneralRuleButtonPressed(sender: AnyObject) {
        
        let popover = NSPopover()
        popover.animates = true
        popover.behavior = .Semitransient
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        
        if availableGeneralRulesViewController == nil {
            availableGeneralRulesViewController = AvailableRulesViewController(nibName:"AvailableRulesViewController", bundle:NSBundle(identifier:"com.andris.FilamentKit"))
        }
        availableGeneralRulesViewController!.availableRules = presenter
        availableGeneralRulesViewController!.displayRulesForNodeType = [.Generic]
        availableGeneralRulesViewController!.collectionViewDelegate = self
        popover.contentViewController = availableGeneralRulesViewController
        
        //TODO: Select between preferred Edges..
        popover.showRelativeToRect(addGenericRuleButton.frame, ofView:self, preferredEdge:.MaxY )
        
    }
    
    
    func refreshGeneralRulesCollectionView() {
        
        generalRulesCollectionView.rulePresenters = presenter?.currentRulePresenters()
        generalRulesCollectionView.reloadData()
        availableGeneralRulesViewController?.reloadCollectionView()
    }
    
    
    
    
    @IBAction func favouriteButtonPressed(sender: AnyObject) {
    }
    
    

    
    // MARK: Presenter Delegate
    
    public func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenter) {
        updateCellView()
    }
    
    
    public func sequencePresenterDidChangeStatus(sequencePresenter: SequencePresenter, toStatus:SequenceStatus){
        
        //  self.collectionView.toolTip = String(presenter!.status)
    }
    
    public func sequencePresenterDidChangeGeneralRules(sequencePresenter: SequencePresenter) {
    
        refreshGeneralRulesCollectionView()
    }
    
    
    
    
    //MARK: RuleCollectionView Delegates
    
    public func didAcceptDrop(collectionView: RuleCollectionView, droppedRulePresenter: RulePresenter, atIndex: Int) {
        
        presenter?.addRulePresenter(droppedRulePresenter, atIndex: atIndex)
        // refreshGeneralRulesCollectionView()
    }
    
    public func didDeleteRulePresenter(collectionView: RuleCollectionView, deletedRulePresenter: RulePresenter) {
        presenter?.removeRulePresenter(deletedRulePresenter)
        //refreshGeneralRulesCollectionView()
    }
    
    public func didDoubleClick(collectionView: RuleCollectionView, selectedRulePresenter: RulePresenter) {
        
        presenter?.addRulePresenter(selectedRulePresenter, atIndex: presenter!.currentRulePresenters().count)
    }
    
}


extension NSView {
    
    var backgroundColor: NSColor? {
        get {
            guard let layer = layer, backgroundColor = layer.backgroundColor else { return nil }
            return NSColor(CGColor: backgroundColor)
        }
        
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.CGColor
        }
    }
}