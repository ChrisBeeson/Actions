//
//  RuleCollectionView.swift
//  Filament
//
//  Created by Chris on 1/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public protocol RuleCollectionViewDelegate {
    
    func didAcceptDrop(collectionView: RuleCollectionView, droppedRulePresenter: RulePresenter, atIndex: Int)
    func didDeleteRulePresenter(collectionView: RuleCollectionView, deletedRulePresenter: RulePresenter)
}


public class RuleCollectionView : NSCollectionView, NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {
    
    public var rulePresenters : [RulePresenter]?
    public var showDetailView = false
    public var allowDrops = false
    public var allowDeletions = false
    public var ruleCollectionViewDelegate : RuleCollectionViewDelegate?
    public var doubleClickDisplaysItemsDetailView = true
    
    
    // MARK: Life Cycle
    
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
        
        let nib = NSNib(nibNamed: "RuleCollectionItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))
        self.registerNib(nib, forItemWithIdentifier: "RuleCollectionItem")
    }
    
    
    
    override public func keyDown(theEvent: NSEvent) {
        
        guard allowDeletions == true else { return }
        
        if theEvent.keyCode == 51 || theEvent.keyCode == 117  {
            for index in self.selectionIndexPaths {
                ruleCollectionViewDelegate?.didDeleteRulePresenter(self, deletedRulePresenter: rulePresenters![index.item])
            }
        }
    }
    
    
    
    //MARK: Datasource
    
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
    
    
    
    //MARK: Collection View Delegate
    
    public func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> NSSize {
        
            let string:NSString = rulePresenters![indexPath.item].name as NSString
            let size: CGSize = string.sizeWithAttributes([NSFontAttributeName: NSFont.systemFontOfSize(12.0, weight:NSFontWeightRegular) ])
            return NSSize(width: size.width + 30, height: 16)
    }
    
    public func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 3.0
    }
    
    public func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2.0
    }
    
    
    public func collectionView(collectionView: NSCollectionView, willDisplayItem item: NSCollectionViewItem, forRepresentedObjectAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    // Drop and Drag
    
    
    public func collectionView(collectionView: NSCollectionView, canDragItemsAtIndexPaths indexPaths: Set<NSIndexPath>, withEvent event: NSEvent) -> Bool {
        
        return true
    }
    
    public func collectionView(collectionView: NSCollectionView, pasteboardWriterForItemAtIndexPath indexPath: NSIndexPath) -> NSPasteboardWriting? {
        
        return rulePresenters?[indexPath.item].draggingItem()
    }
    
  /*
    
    public func collectionView(collectionView: NSCollectionView, draggingImageForItemsAtIndexPaths indexPaths: Set<NSIndexPath>, withEvent event: NSEvent, offset dragImageOffset: NSPointPointer) -> NSImage {
    let item = self.itemAtIndex(indexPaths[0].item)
        
        let dataOfView = view.dataWithPDFInsideRect(view.bounds)
        let imageOfView = NSImage(data: dataOfView)
    }
    */
    
    // drop
    
    
    public func collectionView(collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath?>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        
        if allowDrops && draggingInfo.draggingSource()! !== self {
            return NSDragOperation.Copy
        } else {
            return NSDragOperation.None
        }
    }
    
    
    public func collectionView(collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: NSIndexPath, dropOperation: NSCollectionViewDropOperation) -> Bool {
        
        draggingInfo.enumerateDraggingItemsWithOptions([], forView: self, classes: [NSPasteboardItem.self], searchOptions: [NSPasteboardURLReadingFileURLsOnlyKey: false]) {draggingItem, idx, stop in
            
            if let type = draggingItem.item.types {
                
                switch type![0] {
                    
                case AppConfiguration.UTI.rule:
                    
                    let newRulePresenter = RulePresenter(draggingItem:(draggingItem.item as! NSPasteboardItem))
                    self.ruleCollectionViewDelegate?.didAcceptDrop(self, droppedRulePresenter: newRulePresenter, atIndex:indexPath.item)
                    
                     default: break
                    }
                }
        }
        return true
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
    
}