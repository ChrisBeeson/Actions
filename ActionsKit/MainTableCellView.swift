//
//  SequenceTableRowView.swift
//  Actions
//
//  Created by Chris Beeson on 12/12/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa
import ActionsKit
import Async

public class MainTableCellView: NSTableCellView, SequencePresenterDelegate, RuleCollectionViewDelegate, NSPopoverDelegate {
    
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
    
    public weak var sequencePresenter: SequencePresenter? {
        set {
            sequencePresenter?.removeDelegate(self)
            sequenceCollectionView.presenter = newValue
            if newValue != nil {
                sequencePresenter!.addDelegate(self)
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
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
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
        guard sequencePresenter != nil else { fatalError() }
        
        sequenceCollectionView.reloadData()
        sequenceCollectionView.toolTip = String(sequencePresenter!.currentState)
        
        sequencePresenter!.updateState(processEvents:true)
        titleTextField.stringValue = sequencePresenter!.title
        statusTextField.textColor = colourForCurrentState()
        
        let isCompleted = sequencePresenter!.currentState == .Completed ? true : false
        titleTextField.enabled = !isCompleted
        addGenericRuleButton.hidden = isCompleted
        generalRulesCollectionView.allowDrops = !isCompleted
        generalRulesCollectionView.allowDeletions = !isCompleted
        refreshGeneralRulesCollectionView()
    }
    
    
    @IBAction func titleTextFieldDidChange(sender: NSTextField) {
        sequencePresenter!.renameTitle(sender.stringValue)
    }

    
    @IBAction func addGeneralRuleButtonPressed(sender: AnyObject) {
        guard displayedPopover == nil else { return }
        
        let popover = NSPopover()
        popover.animates = true
        popover.behavior = .Semitransient
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        popover.delegate = self
        
        if availableGeneralRulesViewController == nil {
            availableGeneralRulesViewController = AvailableRulesViewController(nibName:"AvailableRulesViewController", bundle:NSBundle(identifier:"com.andris.ActionsKit"))
        }
        availableGeneralRulesViewController!.availableRules = sequencePresenter
        availableGeneralRulesViewController!.displayRulesForNodeType = [.Generic]
        availableGeneralRulesViewController!.collectionViewDelegate = self
        popover.contentViewController = availableGeneralRulesViewController
        popover.showRelativeToRect(addGenericRuleButton.frame, ofView:rulesStackView, preferredEdge:.MaxX )
    }
    
    
    func refreshGeneralRulesCollectionView() {
        
        let rulePresenters = sequencePresenter?.currentRulePresenters()
        if sequencePresenter != nil {
            rulePresenters?.forEach{ $0.sequencePresenter = sequencePresenter }
        }
        
        // Hide Add General Rules button if there are no available rules
        
        if self.sequencePresenter!.currentState != .Completed {
        if self.sequencePresenter!.availableRulePresenters().count == 0 {
            if addGenericRuleButton.hidden == false {
                addGenericRuleButton.animator().hidden = true
            }
        } else {
           if addGenericRuleButton.hidden == true {
             addGenericRuleButton.animator().hidden = false
            }
        }
        }
        
        self.generalRulesCollectionView.rulePresenters = rulePresenters
        self.generalRulesCollectionView.reloadData()
        //  self.generalRulesCollectionView.needsDisplay = true
        self.availableGeneralRulesViewController?.reloadCollectionView()
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
        
        sequencePresenter?.addRulePresenter(droppedRulePresenter, atIndex: atIndex)
        // refreshGeneralRulesCollectionView()
    }
    
    public func didDeleteRulePresenter(collectionView: RuleCollectionView, deletedRulePresenter: RulePresenter) {
        sequencePresenter?.removeRulePresenter(deletedRulePresenter)
        //refreshGeneralRulesCollectionView()
    }
    
    public func didDoubleClick(collectionView: RuleCollectionView, selectedRulePresenter: RulePresenter) {
        
        sequencePresenter?.addRulePresenter(selectedRulePresenter, atIndex: sequencePresenter!.currentRulePresenters().count)
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
        guard sequencePresenter != nil else { return NSColor.blackColor() }
        
        switch sequencePresenter!.currentState {
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