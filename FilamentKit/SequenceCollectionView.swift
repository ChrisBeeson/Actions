//
//  SequenceCollectionView.swift
//  Filament
//
//  Created by Chris on 5/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

@objc public class SequenceCollectionView : NSCollectionView, NSCollectionViewDataSource, NSCollectionViewDelegate, SequencePresenterDelegate {
    
    enum ItemType: Int { case DateNode, ActionNode, TransitionNode, NewNode }

    public var presenter : SequencePresenter? {
        didSet {
            presenter?.addDelegate(self)
        }
    }
    
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
        
        let nib = NSNib(nibNamed: "DateNodeCollectionViewItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))
        self.registerNib(nib, forItemWithIdentifier: "DateNodeCollectionViewItem")
        
        let actionNib = NSNib(nibNamed: "ActionNodeCollectionViewItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))
        self.registerNib(actionNib, forItemWithIdentifier: "ActionNodeCollectionViewItem")
        
        let transNib = NSNib(nibNamed: "TransitionNodeCollectionViewItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))
        self.registerNib(transNib, forItemWithIdentifier: "TransitionNodeCollectionViewItem")
        
        let addNib = NSNib(nibNamed: "AddNewNodeCollectionViewItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))
        self.registerNib(addNib, forItemWithIdentifier: "AddNewNodeCollectionViewItem")
    }
    

    deinit {
        presenter?.removeDelegate(self)
        presenter = nil
    }
    
    
    //MARK: Datasource
    
    
    public func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return presenter!.nodes!.count + 2
    }
    
    
    public func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        
        let nodes = presenter!.nodes!
        
        if indexPath.item == 0 {
            
            let item = makeItemWithIdentifier("DateNodeCollectionViewItem", forIndexPath: indexPath)
            return item
            
        } else if indexPath.item < nodes.count+1 {
            
            let node = nodes[indexPath.item-1]
            
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
        } else {
            
            // add
            
            let item = makeItemWithIdentifier("AddNewNodeCollectionViewItem", forIndexPath: indexPath) as! AddNewNodeCollectionViewItem
            item.presenter = presenter
            return item
        }
    }
    
    
    //MARK: Sequence Delegate Protocol 
    
    
    public func sequencePresenterDidUpdateChainContents(insertedNodes:[nodeAtIndex], deletedNodes:[nodeAtIndex]) {
        
        self.performBatchUpdates({ () -> Void in
            
            if insertedNodes.count > 0 {
                
                var indexes =  Set<NSIndexPath>()
                
                for node in insertedNodes {
                    indexes.insert(NSIndexPath(forItem: node.0.idx+1, inSection: 0))
                }
                
                self.insertItemsAtIndexPaths(indexes)
            }
            
            
            if deletedNodes.count > 0 {
                var indexes =  Set<NSIndexPath>()
                
                for node in deletedNodes {
                    indexes.insert(NSIndexPath(forItem: node.0.idx+1, inSection: 0))
                }
                
                self.deleteItemsAtIndexPaths(indexes)
            }
            
            }) { (completed) -> Void in
        }
    }
        
    
    //MARK: First Responder Events
    
    override public var acceptsFirstResponder: Bool { return true }
    
    override public func becomeFirstResponder() -> Bool {
        
        dispatch_async(dispatch_get_main_queue()) {
            
        }
        NSNotificationCenter.defaultCenter().postNotificationName("FilamentTableViewSelectCellForView", object: self.superview)
        
        if self.selectionIndexes.count == 0 {
            //   Swift.print(self.superview?.superview?.superview?.superview?.superview)
            
            self.window?.makeFirstResponder(self.superview?.superview?.superview?.superview?.superview?.superview)
            //  return false
            
        }
        
        return true
    }
    
     public func delete(theEvent: NSEvent) {
    
        var nodesToDelete = [Node]()
        
        for indexPath in self.selectionIndexPaths {
            
            if let object = self.itemAtIndexPath(indexPath) {
            
            if object.isKindOfClass(ActionNodeCollectionViewItem) {
                
                let item = object as! ActionNodeCollectionViewItem
                nodesToDelete.append(item.node!)
            }
            }
        }
        
        presenter?.deleteNodes(nodesToDelete)
    }

    override public func keyDown(theEvent: NSEvent) {
        
        if theEvent.keyCode == 51 || theEvent.keyCode == 117  {
            delete(theEvent)
        }
    }



    //MARK: Collection View Delegate
    
    public func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> NSSize {
        
        let nodes = presenter!.nodes!
        
        if indexPath.item == 0 {
            
            return NSSize(width: 60,height: 35)
        }
            
        else if indexPath.item < nodes.count+1 {
            
            let node = nodes[indexPath.item-1]
            
            switch node.type {
                
                //TODO: Get real sizes for these 
                
            case .Action:
                
                if let item = collectionView.itemAtIndex(indexPath.item) {
                     return NSSize(width: 100,height: 35)
                    //Swift.print("using real size of view")
                    //return item.view.intrinsicContentSize
                    
                } else {
                    return NSSize(width: 100,height: 35)
                }
                
            case .Transition:
                return NSSize(width: 50,height: 35)
                
            default:
                return NSSize(width: 30,height: 35)
            }
        } else {
            
            return NSSize(width: 40,height: 50)
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
        
        self.window?.makeFirstResponder(self.superview?.superview?.superview?.superview?.superview?.superview)
        
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