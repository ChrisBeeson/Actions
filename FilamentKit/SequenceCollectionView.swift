//
//  SequenceCollectionView.swift
//  Filament
//
//  Created by Chris on 5/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class SequenceCollectionView : NSCollectionView, NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    public var sequence: Sequence? {
        didSet {
            //  reloadData()
        }
    }
    
    // MARK: Inits
    
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
        
        let nib = NSNib(nibNamed: "DateNodeCollectionViewItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))
        self.registerNib(nib, forItemWithIdentifier: "DateNodeCollectionViewItem")
        
        let actionNib = NSNib(nibNamed: "ActionNodeCollectionViewItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))
        self.registerNib(actionNib, forItemWithIdentifier: "ActionNodeCollectionViewItem")
        
        let transNib = NSNib(nibNamed: "TransitionNodeCollectionViewItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))
        self.registerNib(transNib, forItemWithIdentifier: "TransitionNodeCollectionViewItem")
    }
    
    
    
    override public func selectItemsAtIndexPaths(indexPaths: Set<NSIndexPath>, scrollPosition: NSCollectionViewScrollPosition) {
        
        Swift.print("selecting")
    }
    

    
    
    //MARK: Datasource
    
    public func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        assert(sequence != nil)
        let count = sequence!.allNodes().count+1
        return count
    }
    
    
    public func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        
        if indexPath.item == 0 {
            
            let item = makeItemWithIdentifier("DateNodeCollectionViewItem", forIndexPath: indexPath)
            return item
            
        } else {
            
            let node = sequence!.allNodes()[indexPath.item-1]
            
            switch node.type {
            case .Action:
                let item = makeItemWithIdentifier("ActionNodeCollectionViewItem", forIndexPath: indexPath) as! ActionNodeCollectionViewItem
                item.node = node
                item.indexPath = indexPath
                return item
                
            case .Transition:
                let item = makeItemWithIdentifier("TransitionNodeCollectionViewItem", forIndexPath: indexPath)
                return item
                
            default:
                return NSCollectionViewItem()
            }
        }
    }
    
    //MARK: Delegate
    
    public func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> NSSize {
        
        if indexPath.item == 0 {
            
            return NSSize(width: 55,height: 35)
        }
            
        else {
            
            let node = sequence!.allNodes()[indexPath.item-1]
            
            switch node.type {
                
                //TODO: Get real sizes for these 
                
            case .Action:
                
                if let item = collectionView.itemAtIndex(indexPath.item) {
                    Swift.print("using real size of view")
                return item.view.intrinsicContentSize
                    
                } else {
                    return NSSize(width: 100,height: 35)
                }
                
            case .Transition:
                return NSSize(width: 30,height: 35)
                
            default:
                return NSSize(width: 30,height: 35)
            }
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
        
    }
    
    /* Sent at the end of interactive selection, to inform the delegate that the CollectionView has de-selected the items at the specified "indexPaths".
    */

    public func collectionView(collectionView: NSCollectionView, didDeselectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
        
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