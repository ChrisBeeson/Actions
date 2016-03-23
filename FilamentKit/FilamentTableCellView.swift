//
//  SequenceTableRowView.swift
//  Filament
//
//  Created by Chris Beeson on 12/12/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa
import FilamentKit
import Async

public class FilamentTableCellView: NSTableCellView, SequencePresenterDelegate, RuleCollectionViewDelegate, NSPopoverDelegate {
    
    override public var acceptsFirstResponder: Bool { return true }
    
    @IBOutlet weak var backgroundView: NSView!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var sequenceCollectionView: SequenceCollectionView!
    @IBOutlet weak var scrollview: NSScrollView!
    
    @IBOutlet weak var mainStackView: NSStackView!
    @IBOutlet weak var addGenericRuleButton: NSButton!
    @IBOutlet weak var generalRulesCollectionView: RuleCollectionView!
    
    @IBOutlet weak var statusTextField: NSTextField!
    @IBOutlet weak var rulesStackView: NSStackView!
    private var availableGeneralRulesViewController : AvailableRulesViewController?
    private var displayedPopover: NSPopover?
    
    public weak var presenter: SequencePresenter? {
        
        set {
            presenter?.removeDelegate(self)
            sequenceCollectionView.presenter = newValue
            if newValue != nil {
                presenter!.addDelegate(self)
            }
        }
        
        get {
            return sequenceCollectionView.presenter
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
                backgroundView.layer?.borderWidth = 0.2
                backgroundView.layer?.borderColor = NSColor.grayColor().CGColor
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
        
        scrollview.horizontalScroller?.alphaValue = 0.0
        backgroundView.backgroundColor = NSColor.whiteColor()
        backgroundView.layer?.borderWidth = 0.2
        backgroundView.layer?.borderColor = NSColor.grayColor().CGColor
    }
    
    
    func updateCellView() {
        guard presenter != nil else { fatalError() }
        
        presenter!.updateState(true)
        titleTextField.stringValue = presenter!.title
        self.sequenceCollectionView.toolTip = String(presenter!.currentState)
        sequenceCollectionView.reloadData()
        
        // Hide & disable things if we're .Completed
        //  Swift.print("updating Cell view to state \(presenter!.currentState)")
        let isCompleted = presenter!.currentState == .Completed ? true : false
        titleTextField.enabled = !isCompleted
        titleTextField.setNeedsDisplay()
        addGenericRuleButton.hidden = isCompleted
        generalRulesCollectionView.allowDrops = !isCompleted
        generalRulesCollectionView.allowDeletions = !isCompleted
        refreshGeneralRulesCollectionView()
        statusTextField.animator().textColor = colourForCurrentState()
        
        self.sequenceCollectionView.toolTip = String(presenter!.currentState)
        
        self.needsDisplay = true
    }
    
    
    @IBAction func titleTextFieldDidChange(sender: NSTextField) {
        
        presenter!.renameTitle(sender.stringValue)
    }

    
    @IBAction func addGeneralRuleButtonPressed(sender: AnyObject) {
        guard displayedPopover == nil else { return }
        
        let popover = NSPopover()
        popover.animates = true
        popover.behavior = .Semitransient
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        popover.delegate = self
        
        if availableGeneralRulesViewController == nil {
            availableGeneralRulesViewController = AvailableRulesViewController(nibName:"AvailableRulesViewController", bundle:NSBundle(identifier:"com.andris.FilamentKit"))
        }
        availableGeneralRulesViewController!.availableRules = presenter
        availableGeneralRulesViewController!.displayRulesForNodeType = [.Generic]
        availableGeneralRulesViewController!.collectionViewDelegate = self
        popover.contentViewController = availableGeneralRulesViewController
        popover.showRelativeToRect(addGenericRuleButton.frame, ofView:rulesStackView, preferredEdge:.MaxX )
        
    }
    
    
    func refreshGeneralRulesCollectionView() {
        
        let rulePresenters = presenter?.currentRulePresenters()
        if presenter != nil {
            rulePresenters?.forEach{ $0.sequencePresenter = presenter }
        }
        
        // Hide Add General Rules button if there are no available rules
        
        if self.presenter!.currentState != .Completed {
        if self.presenter!.availableRulePresenters().count == 0 {
            if addGenericRuleButton.hidden == false {
                addGenericRuleButton.animator().hidden = true
            }
        } else {
           if addGenericRuleButton.hidden == true {
             addGenericRuleButton.animator().hidden = false
            }
        }
        }
        
        // Async.main(after:0.05) {
        self.generalRulesCollectionView.rulePresenters = rulePresenters
        self.generalRulesCollectionView.reloadData()
        //  self.generalRulesCollectionView.needsDisplay = true
        self.availableGeneralRulesViewController?.reloadCollectionView()
        // }
    }
    
    
    //MARK: Events
    /*
    public func copy(event: NSEvent) {
    
    }
    */
    
    
    // MARK: Presenter Delegate
    
    public func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenter) {
        updateCellView()
    }
    
    
    public func sequencePresenterDidChangeState(sequencePresenter: SequencePresenter, toState:SequenceState) {
        updateCellView()
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
        displayedPopover?.close()
    }
    

    
    //MARK: NSPopover Delegate
    
    public func popoverWillShow(notification: NSNotification) {
        displayedPopover = notification.object as? NSPopover
    }
    
    public func popoverDidClose(notification: NSNotification) {
        displayedPopover = nil
    }
    
    // Colour
    
    func colourForCurrentState() -> NSColor {
        guard presenter != nil else { return NSColor.blackColor() }
        
        switch presenter!.currentState {
        case .NoStartDateSet: return AppConfiguration.Palette.verylightGreyStroke
        case .WaitingForStart: return AppConfiguration.Palette.greenStroke
        case .Running: return AppConfiguration.Palette.greenStroke
        case .Completed: return AppConfiguration.Palette.lightGreyStroke
        case .Paused: return AppConfiguration.Palette.blueStroke
        case .HasFailedNode: return AppConfiguration.Palette.redStroke
        default : return NSColor.blackColor()
        }
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