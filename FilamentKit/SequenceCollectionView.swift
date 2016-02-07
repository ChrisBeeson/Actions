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
        
        let gridLayout = NSCollectionViewGridLayout()
        gridLayout.minimumItemSize = NSSize(width: 20, height: 35)
        gridLayout.maximumItemSize = NSSize(width: 175, height: 35)
        gridLayout.minimumInteritemSpacing = 0
        gridLayout.margins = NSEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.collectionViewLayout = gridLayout
        
        self.dataSource = self
        self.delegate = self
        
        let nib = NSNib(nibNamed: "DateNodeCollectionViewItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))
        self.registerNib(nib, forItemWithIdentifier: "DateNodeCollectionViewItem")
    }

    
    
    //MARK: Datasource

    public func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    
        assert(sequence != nil)
        let count = sequence!.allNodes().count+1
        return count
    }


    public func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        
        let item : NSCollectionViewItem

        if indexPath.item != -1 {
            
            item = makeItemWithIdentifier("DateNodeCollectionViewItem", forIndexPath: indexPath)
            
            // item = DateNodeCollectionViewItem(nibName: "DateNodeCollectionViewItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))!
            //   item.representedObject = Sequence()
            
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

        //  item.loadView()
        // Swift.print(item)
        return item
    }
    
    //MARK: Delegate
    
    public func collectionView(collectionView: NSCollectionView, willDisplayItem item: NSCollectionViewItem, forRepresentedObjectAtIndexPath indexPath: NSIndexPath) {
        Swift.print("will display")
        ///   let frame = frameForItemAtIndex(indexPath.item)
        // item.view.frame = frame
    }
    
   
    
    public func collectionView(collectionView: NSCollectionView, canDragItemsAtIndexPaths indexPaths: Set<NSIndexPath>, withEvent event: NSEvent) -> Bool {
        
        return true
    }
    
    
    
    
}