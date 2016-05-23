//
//  RuleCollectionItem.swift
//  Actions
//
//  Created by Chris on 1/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class RuleCollectionItem : NSCollectionViewItem, DragDropCopyPasteItem {
    
    @IBOutlet weak var ruleTokenView: RuleTokenView!
    @IBOutlet weak var label: NSTextField!
    
    var doubleClickDisplaysDetailView = true
    var rulePresenter: RulePresenter?
    
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
    
    override public func viewWillAppear() {
        super.viewWillAppear()
        updateView()
        ruleTokenView.frame = self.view.bounds   // layout not working 100% and this seems to be a hacky solution
    }
    
    func updateView() {
        if rulePresenter != nil { label.stringValue = rulePresenter!.name as String }
        
        switch currentState {
        case .Active:
            switch selected {
            case true:
                label.textColor = NSColor.whiteColor()
                label.backgroundColor = AppConfiguration.Palette.tokenBlueSelected
                ruleTokenView.setColour(AppConfiguration.Palette.tokenBlueSelected.CGColor)
            case false:
                ruleTokenView.setColour(AppConfiguration.Palette.tokenBlue.CGColor)
                label.backgroundColor = AppConfiguration.Palette.tokenBlue
                label.textColor = NSColor.blackColor()
            }
        case .Inactive:
            label.textColor = NSColor.whiteColor()
            label.backgroundColor = AppConfiguration.Palette.tokenInactive
            ruleTokenView.setColour(AppConfiguration.Palette.tokenInactive.CGColor)
            
        case .Error:
            label.textColor = NSColor.whiteColor()
            ruleTokenView.setColour(AppConfiguration.Palette.tokenError.CGColor)
        }
        self.view.needsDisplay = true
    }
    
    override public func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
        if currentState == .Inactive { return }
        if theEvent.clickCount < 2 { return }
        if doubleClickDisplaysDetailView == false { return }
        guard rulePresenter != nil else { fatalError("Trying to display Rule detail view, when presenter is Nil") }
        
        // TODO: Don't show popover if it's currently displayed
        
        let detailView = rulePresenter!.detailViewController()
        let popover = NSPopover()
        popover.animates = true
        popover.behavior = .Transient
        popover.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
        popover.contentViewController = detailView
        popover.showRelativeToRect(self.view.frame, ofView: self.view.superview!, preferredEdge:.MaxY )
    }
    
    //MARK: Copy & Paste
    
    func pasteboardItem() -> NSPasteboardItem {
        return rulePresenter!.pasteboardItem()
    }
    
    //MARK: Drag & Drop
    
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