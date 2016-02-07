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
    }
    
    
    //MARK: Datasource

    public func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    
        assert(sequence != nil)
        let count = sequence!.allNodes().count+1
        Swift.print("There are \(count) items in the collectionView")
        return count
    }


    public func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        
        let item : NSCollectionViewItem

        if indexPath.item == 0 {
            
            item = DateNodeCollectionViewItem(nibName: "DateNodeCollectionViewItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))!
            item.representedObject = Sequence()
            
        } else {
            
            let node = sequence!.allNodes()[indexPath.item-1]
            
            switch node.type {
            case .Action:
                item = ActionNodeCollectionViewItem(node: node)
            
            case .Transition:
                item = TransitionNodeCollectionViewItem(node: node)
                
             default:
                item = NSCollectionViewItem()
            }
        }
        
        Swift.print(item)
        return item
    }
    
    //MARK: Delegate
    
    public func collectionView(collectionView: NSCollectionView, willDisplayItem item: NSCollectionViewItem, forRepresentedObjectAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    public func collectionView(collectionView: NSCollectionView, canDragItemsAtIndexPaths indexPaths: Set<NSIndexPath>, withEvent event: NSEvent) -> Bool {
        
        return true
    }
}