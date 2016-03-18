//
//  SequenceCollectionView.swift
//  Filament
//
//  Created by Chris on 5/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import Async

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
        //self.collectionViewLayout = LeftAlignedCollectionViewFlowLayout()
        
        //self.wantsLayer = true
        
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
    
        switch presenter!.currentState {
            
        case .Completed:
            return presenter!.nodes!.count + 1
        default:
            return presenter!.nodes!.count + 2
        }
    }
    
    
    public func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        
        let nodes = presenter!.nodes!
        
        if indexPath.item == 0 {
            
            let item = makeItemWithIdentifier("DateNodeCollectionViewItem", forIndexPath: indexPath) as! DateNodeCollectionViewItem
            item.sequencePresenter = self.presenter!
            presenter?.addDelegate(item)
            item.updateView()
            return item
            
        } else if indexPath.item < nodes.count+1 {
            
            let node = nodes[indexPath.item-1]
            var item: NodeCollectionViewItem
            
            switch node.type {
                
            case NodeType.Action:
                 item = makeItemWithIdentifier("ActionNodeCollectionViewItem", forIndexPath: indexPath) as! NodeCollectionViewItem
                
            case NodeType.Transition:
                 item = makeItemWithIdentifier("TransitionNodeCollectionViewItem", forIndexPath: indexPath) as! NodeCollectionViewItem
                
            default:
                fatalError("Invaild Node Type for CollectionView")
            }
            
            item.presenter = presenter!.presenterForNode(node)
            item.updateView()
            item.indexPath = indexPath
            return item
      
        } else {
            
            let item = makeItemWithIdentifier("AddNewNodeCollectionViewItem", forIndexPath: indexPath) as! AddNewNodeCollectionViewItem
            item.sequencePresenter = presenter
            return item
        }
    }
    
    
    //MARK: Sequence Delegate Protocol 
    
    
    public func sequencePresenterDidUpdateChainContents(insertedNodes:Set<NSIndexPath>, deletedNodes:Set<NSIndexPath>) {
        
        // Async.main { [unowned self] in
            
        self.performBatchUpdates({ () -> Void in
            
            if insertedNodes.count > 0 {
                self.animator().insertItemsAtIndexPaths(insertedNodes)
            }
            
            if deletedNodes.count > 0 {
                self.animator().deleteItemsAtIndexPaths(deletedNodes)
            }
            }) { (completed) -> Void in
        }
              self.reloadData()
    
    }
    
    
    //MARK: Events

    public func copy(event: NSEvent) {
        Swift.print("seq collection copy")
    }
    
    
     public func delete(theEvent: NSEvent) {
    
        var nodesToDelete = [Node]()
        
        for indexPath in self.selectionIndexPaths {
            
            if let object = self.itemAtIndexPath(indexPath) {
            
            if object.isKindOfClass(NodeCollectionViewItem) {
                
                let item = object as! NodeCollectionViewItem
                assert(item.presenter!.type == .Action,"Trying to delete a non .Action node")
                nodesToDelete.append(item.presenter!.node)
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
            
            case [.Action]:
                
                if let item = collectionView.itemAtIndex(indexPath.item) {
                    return item.view.intrinsicContentSize
                    
                } else {
                    let string:NSString = node.title as NSString
                    let size: CGSize = string.sizeWithAttributes([NSFontAttributeName: NSFont.systemFontOfSize(14.0, weight:NSFontWeightThin) ])
                    return NSSize(width: size.width + 30.2, height: 35)
                }
                
            case [.Transition]:
                
                if let item = collectionView.itemAtIndex(indexPath.item) {
                    return item.view.intrinsicContentSize
                    
                } else {
                    let string:NSString = node.title as NSString
                    let size: CGSize = string.sizeWithAttributes([NSFontAttributeName: NSFont.systemFontOfSize(9, weight:NSFontWeightRegular) ])
                    return NSSize(width: size.width + 30, height: 25)
                }
                
            default:
                return NSSize(width: 30,height: 25)
            }
        } else {
            
            return NSSize(width: 40,height: 25)
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
    
    //MARK: First Responder Events
    
    override public var acceptsFirstResponder: Bool { return true }
    
    override public func becomeFirstResponder() -> Bool {
        
        NSNotificationCenter.defaultCenter().postNotificationName("FilamentTableViewSelectCellForView", object: self.superview)
        
        if self.selectionIndexes.count == 0 {
            self.window?.makeFirstResponder(self.superview?.superview?.superview?.superview?.superview?.superview)
        }
        return true
    }
    
}