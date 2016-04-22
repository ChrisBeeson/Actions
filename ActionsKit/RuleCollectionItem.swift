//
//  RuleCollectionItem.swift
//  Actions
//
//  Created by Chris on 1/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation



public class RuleCollectionItem : NSCollectionViewItem, DragDropCopyPasteItem {
    
    @IBOutlet weak var rulePillView: RulePillView!
    @IBOutlet weak var label: NSTextField!
    
    var doubleClickDisplaysDetailView = true
    var rulePresenter: RulePresenter?
    
    // TODO: Add PopoverCurrentlyDisplayed
    
    var currentState: RuleState {
        if rulePresenter == nil { return .Inactive }
        return rulePresenter!.currentState
    }
    
    override public var selected: Bool {
        didSet {
            updateView()
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override public func viewWillLayout() {
        super.viewWillLayout()
    }
    
    override public func viewWillAppear() {
        super.viewWillAppear()
        updateView()
        rulePillView.frame = self.view.bounds   // layout not working 100% and this seems to be a hacky solution
    }
    
    
    func updateView() {
        if rulePresenter != nil { label.stringValue = rulePresenter!.name as String }
        
        switch currentState {
        case .Active:
            switch selected {
            case true:
                label.textColor = NSColor.whiteColor()
                rulePillView.setColour(AppConfiguration.Palette.tokenBlueSelected.CGColor)
            case false:
                rulePillView.setColour(AppConfiguration.Palette.tokenBlue.CGColor)
                label.textColor = NSColor.blackColor()
            }
        case .Inactive:
            label.textColor = NSColor.whiteColor()
            rulePillView.setColour(AppConfiguration.Palette.tokenInactive.CGColor)
            
        case .Error:
            label.textColor = NSColor.whiteColor()
            rulePillView.setColour(AppConfiguration.Palette.tokenError.CGColor)
        }
        self.view.needsDisplay = true
    }
    
    override public func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
        
        if currentState == .Inactive { return }
        if theEvent.clickCount < 2 { return }
        if doubleClickDisplaysDetailView == false { return }
        guard rulePresenter != nil else { fatalError("Trying to display Rule detail view, when presenter is Nil") }
        
        let popover = NSPopover()
        popover.animates = true
        popover.behavior = .Transient
        popover.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
        
        let detailView = rulePresenter!.detailViewController()
        popover.contentViewController = detailView
        popover.showRelativeToRect(self.view.frame, ofView: self.view.superview!, preferredEdge:.MaxY )
    }
    
    
    // Copy & Paste
    
    func pasteboardItem() -> NSPasteboardItem {
        return rulePresenter!.pasteboardItem()
    }
    
    // Drag & Drop
    
    func isDraggable() -> Bool {
        return true
    }
    
    func draggingItem() -> NSPasteboardWriting? {
        return pasteboardItem()
    }
    
    func validateDrop(item: NSPasteboardItem, proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        return .None
    }
    
    func acceptDrop(collectionView: NSCollectionView, item: NSPasteboardItem, dropOperation: NSCollectionViewDropOperation) -> Bool {
        return true
    }
    
}