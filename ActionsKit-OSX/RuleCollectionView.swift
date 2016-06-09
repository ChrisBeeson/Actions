//
//  RuleCollectionView.swift
//  Actions
//
//  Created by Chris on 1/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//
import Foundation
import AppKit

public protocol RuleCollectionViewDelegate {
    func didAcceptDrop(collectionView: RuleCollectionView, droppedRulePresenter: RulePresenter, atIndex: Int)
    func didDeleteRulePresenter(collectionView: RuleCollectionView, deletedRulePresenter: RulePresenter)
    func didDoubleClick(collectionView: RuleCollectionView, selectedRulePresenter: RulePresenter)
}

public class RuleCollectionView : NSCollectionView, NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {
    
    public var rulePresenters : [RulePresenter]?
    public var showDetailView = false
    public var allowDrops = false
    public var allowDropsFromType:NodeType = [.Void]
    public var allowDeletions = false
    public var ruleCollectionViewDelegate : RuleCollectionViewDelegate?
    public var doubleClickDisplaysItemsDetailView = true
    private var dragDropInPlaceView:NSView?
    
    
    //MARK: Lifecycle -
    
    public required init(coder aDecoder: NSCoder)  {
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        self.dataSource = self
        self.delegate = self
        self.collectionViewLayout = LeftAlignedCollectionViewFlowLayout()
        self.backgroundColors = [NSColor.clearColor()]
        self.registerForDraggedTypes([AppConfiguration.UTI.rule])
        
        let nib = NSNib(nibNamed: "RuleCollectionItem", bundle: NSBundle(identifier:"com.andris.ActionsKit"))
        self.registerNib(nib, forItemWithIdentifier: "RuleCollectionItem")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    //MARK: Datasource -
    
    public func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard rulePresenters != nil else { return 0 }
        return rulePresenters!.count
    }
    
    public func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        let item = makeItemWithIdentifier("RuleCollectionItem", forIndexPath: indexPath) as! RuleCollectionItem
        item.rulePresenter = rulePresenters![indexPath.item]
        item.doubleClickDisplaysDetailView = doubleClickDisplaysItemsDetailView
        return item
    }
    
    
    //MARK: Collection View Delegate -
    
    public func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> NSSize {
        let string:NSString = rulePresenters![indexPath.item].name as NSString
        let size: CGSize = string.sizeWithAttributes([NSFontAttributeName: NSFont.systemFontOfSize(11.5, weight:NSFontWeightRegular) ])
        return NSSize(width: size.width + 20, height: 16)
    }
    
    public func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 3.0
    }
    
    public func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2.0
    }
    
    public func collectionView(collectionView: NSCollectionView, willDisplayItem item: NSCollectionViewItem, forRepresentedObjectAtIndexPath indexPath: NSIndexPath) {
        (item as! RuleCollectionItem).updateView()
    }
    
    
    // Drop and Drag -
    
    public func collectionView(collectionView: NSCollectionView, canDragItemsAtIndexPaths indexPaths: Set<NSIndexPath>, withEvent event: NSEvent) -> Bool {
        return true
    }
    
    public func collectionView(collectionView: NSCollectionView, pasteboardWriterForItemAtIndexPath indexPath: NSIndexPath) -> NSPasteboardWriting? {
        if rulePresenters == nil { Swift.print("Nil") }
        return rulePresenters?[indexPath.item].pasteboardItem()
    }
    
    public func collectionView(collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAtPoint screenPoint: NSPoint, forItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
        
        // This is such a hacky solution!! (But it works!)
        let item = makeItemWithIdentifier("RuleCollectionItem", forIndexPath: indexPaths.first!) as! RuleCollectionItem
        item.rulePresenter = rulePresenters![indexPaths.first!.item]
        dragDropInPlaceView = item.view
        dragDropInPlaceView!.frame = self.frameForItemAtIndex(indexPaths.first!.item)
        self.addSubview(dragDropInPlaceView!)
    }
    
    public func collectionView(collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAtPoint screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
        
        if dragDropInPlaceView != nil {
            dragDropInPlaceView?.removeFromSuperview()
        }
    }
    
    
    public func collectionView(collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath?>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        
        if allowDrops == false { return NSDragOperation.None }
        if draggingInfo.draggingSource()! === self { return NSDragOperation.None }
        
        if let presenter = rulePresenterFromDraggingItem(draggingInfo) {
            if presenter.availableToNodeType.contains(self.allowDropsFromType) {
                for rule in self.rulePresenters! {
                    if rule.name == presenter.name { return NSDragOperation.None }
                }
                return NSDragOperation.Copy
            }
        }
        return NSDragOperation.None
    }
    
    
    public func collectionView(collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: NSIndexPath, dropOperation: NSCollectionViewDropOperation) -> Bool {
        
        if let presenter = rulePresenterFromDraggingItem(draggingInfo) {
            self.ruleCollectionViewDelegate?.didAcceptDrop(self, droppedRulePresenter: presenter, atIndex:indexPath.item)
            return true
        }
        return false
    }
    
    
    func rulePresenterFromDraggingItem(draggingInfo: NSDraggingInfo) -> RulePresenter? {
        var presenter : RulePresenter?
    
        draggingInfo.enumerateDraggingItemsWithOptions([], forView: self, classes: [NSPasteboardItem.self], searchOptions: [NSPasteboardURLReadingFileURLsOnlyKey: false]) {draggingItem, idx, stop in
            let types = (draggingItem.item as! NSPasteboardItem).types
            if types.count > 0 {
                switch types[0] {
                case AppConfiguration.UTI.rule:
                    presenter = RulePresenter(pasteboardItem:(draggingItem.item as! NSPasteboardItem))
                default: break
                }
            }
        }
        return presenter
    }
    
    public func collectionView(collectionView: NSCollectionView, shouldChangeItemsAtIndexPaths indexPaths: Set<NSIndexPath>, toHighlightState highlightState: NSCollectionViewItemHighlightState) -> Set<NSIndexPath> {
        return indexPaths
    }
    
    public func collectionView(collectionView: NSCollectionView, didChangeItemsAtIndexPaths indexPaths: Set<NSIndexPath>, toHighlightState highlightState: NSCollectionViewItemHighlightState) {
    }
    
    public func collectionView(collectionView: NSCollectionView, shouldSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) -> Set<NSIndexPath> {
        return indexPaths
    }
    
    public func collectionView(collectionView: NSCollectionView, shouldDeselectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) -> Set<NSIndexPath> {
        return indexPaths
    }
    
    public func collectionView(collectionView: NSCollectionView, didSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
        self.window?.makeFirstResponder(self)
    }
    
    public func collectionView(collectionView: NSCollectionView, didDeselectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
        self.window?.makeFirstResponder(self.superview?.superview?.superview?.superview?.superview?.superview)
    }
    
    public func collectionView(collectionView: NSCollectionView, willDisplaySupplementaryView view: NSView, forElementKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
    }
    
    public func collectionView(collectionView: NSCollectionView, didEndDisplayingItem item: NSCollectionViewItem, forRepresentedObjectAtIndexPath indexPath: NSIndexPath) {
    }
    
    
    //MARK: Events -
    
    override public func keyDown(theEvent: NSEvent) {
        guard allowDeletions == true else { return }
        if theEvent.keyCode == 51 || theEvent.keyCode == 117  {
            for index in self.selectionIndexPaths {
                ruleCollectionViewDelegate?.didDeleteRulePresenter(self, deletedRulePresenter: rulePresenters![index.item])
            }
        }
    }
    
    public func copy(event: NSEvent) {
        if self.selectionIndexPaths.count > 0 {
            NSPasteboard.generalPasteboard().clearContents()
            var items = [NSPasteboardWriting]()
            for index in self.selectionIndexPaths {
                let item = (self.itemAtIndexPath(index) as! DragDropCopyPasteItem)
                items.append(item.pasteboardItem())
            }
            NSPasteboard.generalPasteboard().clearContents()
            NSPasteboard.generalPasteboard().writeObjects(items)
        }
    }
    
    public func paste(event: NSEvent) {
        if NSPasteboard.generalPasteboard().canReadItemWithDataConformingToTypes([AppConfiguration.UTI.rule]) != true { return }
        Swift.print("Paste Rule")
    }
    
    override public func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
        
        if theEvent.clickCount < 2 { return }
        if doubleClickDisplaysItemsDetailView == true { return }
        
        if self.selectionIndexPaths.count > 0 {
            let presenter = rulePresenters![self.selectionIndexPaths.first!.item]
            ruleCollectionViewDelegate?.didDoubleClick(self, selectedRulePresenter: presenter)
        }
    }
    
    //MARK: First responder -
    
    override public func becomeFirstResponder() -> Bool {
        if let view = self.findSuperViewWithClass(NSTableCellView) {
            NSNotificationCenter.defaultCenter().postNotificationName("ActionsTableViewSelectCellForView", object: self.superview)
            if self.selectionIndexes.count == 0 {
                self.window?.makeFirstResponder(view)
            }
        }
        return true
    }
    
    override public func resignFirstResponder() -> Bool {
        self.deselectAll(self)
        return true
    }
}