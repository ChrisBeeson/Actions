//
//  RuleCollectionView.swift
//  Filament
//
//  Created by Chris on 1/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class RuleCollectionView : NSCollectionView, NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {
    
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
        //    self.wantsLayer = true
        
        let nib = NSNib(nibNamed: "RuleCollectionItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))
        self.registerNib(nib, forItemWithIdentifier: "RuleCollectionItem")
    }
    
    
    
    
    //MARK: Datasource
    
    public func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    
    public func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 20
        
    }
    
    
    public func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {

            let item = makeItemWithIdentifier("RuleCollectionItem", forIndexPath: indexPath)
        
        Swift.print(item)
            return item
    }
    
    
    
    //MARK: Collection View Delegate
    
    public func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> NSSize {
        
        

                if let item = collectionView.itemAtIndex(indexPath.item) {
                    return item.view.intrinsicContentSize
                    
                } else {
                    
                    return NSSize(width: 82, height: 27)
             
                    /*
                    let string:NSString = node.title as NSString
                    let size: CGSize = string.sizeWithAttributes([NSFontAttributeName: NSFont.systemFontOfSize(14.0, weight:NSFontWeightThin) ])
                    return NSSize(width: size.width + 30.5, height: 35)
                    
                    */
                }
                

    
    }
    
    public func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    public func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    
    public func collectionView(collectionView: NSCollectionView, willDisplayItem item: NSCollectionViewItem, forRepresentedObjectAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    public func collectionView(collectionView: NSCollectionView, canDragItemsAtIndexPaths indexPaths: Set<NSIndexPath>, withEvent event: NSEvent) -> Bool {
        
        return true
    }
    
    
    /////////////
    
    public func collectionView(collectionView: NSCollectionView, shouldChangeItemsAtIndexPaths indexPaths: Set<NSIndexPath>, toHighlightState highlightState: NSCollectionViewItemHighlightState) -> Set<NSIndexPath> {
        return indexPaths
    }
    
    public func collectionView(collectionView: NSCollectionView, didChangeItemsAtIndexPaths indexPaths: Set<NSIndexPath>, toHighlightState highlightState: NSCollectionViewItemHighlightState) {
        
    }
    
    /* Sent during interactive selection, to inform the delegate that the CollectionView would like to select the items at the specified "indexPaths".  In addition to optionally reacting to the proposed change, you can approve it (by returning "indexPaths" as-is), or selectively refuse some or all of the proposed selection changes (by returning a modified autoreleased mutableCopy of indexPaths, or an empty indexPaths instance).
    */
    
    public func collectionView(collectionView: NSCollectionView, shouldSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) -> Set<NSIndexPath> {
        return indexPaths
    }
    
    /* Sent during interactive selection, to inform the delegate that the CollectionView would like to de-select the items at the specified "indexPaths".  In addition to optionally reacting to the proposed change, you can approve it (by returning "indexPaths" as-is), or selectively refuse some or all of the proposed selection changes (by returning a modified autoreleased mutableCopy of indexPaths, or an empty indexPaths instance). */
    
    public func collectionView(collectionView: NSCollectionView, shouldDeselectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) -> Set<NSIndexPath> {
        return indexPaths
        
    }
    
    /* Sent at the end of interactive selection, to inform the delegate that the CollectionView has selected the items at the specified "indexPaths".
    */
    
    public func collectionView(collectionView: NSCollectionView, didSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
        
        self.window?.makeFirstResponder(self)
        
    }
    
    /* Sent at the end of interactive selection, to inform the delegate that the CollectionView has de-selected the items at the specified "indexPaths".
    */
    
    public func collectionView(collectionView: NSCollectionView, didDeselectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
        self.window?.makeFirstResponder(self.superview?.superview?.superview?.superview?.superview?.superview)
    }
    
    
    /* Sent to notify the delegate that the CollectionView is about to add a supplementary view (e.g. a section header or footer view).  Each NSCollectionViewLayout class defines its own possible values and associated meanings for "elementKind".  (For example, NSCollectionViewFlowLayout declares NSCollectionElementKindSectionHeader and NSCollectionElementKindSectionFooter.)
    */
    
    public func collectionView(collectionView: NSCollectionView, willDisplaySupplementaryView view: NSView, forElementKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        
    }
    
    /* Sent to notify the delegate that the CollectionView is no longer displaying the given NSCollectionViewItem instance.  This happens when the model changes, or when an item is scrolled out of view.  You should perform any actions necessary to help decommission the item (such as releasing expensive resources).  The CollectionView may retain the item instance and later reuse it to represent the same or a different model object.
    */
    
    public func collectionView(collectionView: NSCollectionView, didEndDisplayingItem item: NSCollectionViewItem, forRepresentedObjectAtIndexPath indexPath: NSIndexPath) {
        
    }

}