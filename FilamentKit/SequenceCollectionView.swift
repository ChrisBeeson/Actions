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
        /*
        let gridLayout = NSCollectionViewGridLayout()
        gridLayout.minimumItemSize = NSSize(width: 20, height: 35)
        gridLayout.maximumItemSize = NSSize(width: 175, height: 35)
        gridLayout.minimumInteritemSpacing = 0
        gridLayout.margins = NSEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.collectionViewLayout = gridLayout
        */
        self.dataSource = self
        self.delegate = self
        
        let nib = NSNib(nibNamed: "DateNodeCollectionViewItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))
        self.registerNib(nib, forItemWithIdentifier: "DateNodeCollectionViewItem")
        
        let actionNib = NSNib(nibNamed: "ActionNodeCollectionViewItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))
        self.registerNib(actionNib, forItemWithIdentifier: "ActionNodeCollectionViewItem")
        
        let transNib = NSNib(nibNamed: "TransitionNodeCollectionViewItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))
        self.registerNib(transNib, forItemWithIdentifier: "TransitionNodeCollectionViewItem")
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
    
    public func collectionView(collectionView: NSCollectionView, willDisplayItem item: NSCollectionViewItem, forRepresentedObjectAtIndexPath indexPath: NSIndexPath) {

    }
    
   
    
    public func collectionView(collectionView: NSCollectionView, canDragItemsAtIndexPaths indexPaths: Set<NSIndexPath>, withEvent event: NSEvent) -> Bool {
        
        return true
    }
    
    
    
    
}