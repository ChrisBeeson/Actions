//
//  LeftAlignedCollectionViewFlowLayout.swift
//  Filament
//
//  Created by Chris on 3/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//


import Foundation

class LeftAlignedCollectionViewFlowLayout: NSCollectionViewFlowLayout {
    
    var maximumCellSpacing = CGFloat(2.0)
    
    override func layoutAttributesForElementsInRect(rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        
        let attributesToReturn = super.layoutAttributesForElementsInRect(rect)
        
        for attributes in attributesToReturn ?? [] {
            if attributes.representedElementKind == nil {
                attributes.frame = self.layoutAttributesForItemAtIndexPath(attributes.indexPath!)!.frame
            }
        }
        return attributesToReturn
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> NSCollectionViewLayoutAttributes? {
        
        let curAttributes = super.layoutAttributesForItemAtIndexPath(indexPath)
        let sectionInset = (self.collectionView?.collectionViewLayout as! NSCollectionViewFlowLayout).sectionInset
        
        if indexPath.item == 0 {
            let f = curAttributes!.frame
            curAttributes!.frame = CGRectMake(sectionInset.left, f.origin.y, f.size.width, f.size.height)
            return curAttributes
        }
        
        let prevIndexPath = NSIndexPath(forItem: indexPath.item-1, inSection: indexPath.section)
        let prevFrame = self.layoutAttributesForItemAtIndexPath(prevIndexPath)!.frame
        let prevFrameRightPoint = prevFrame.origin.x + prevFrame.size.width + maximumCellSpacing
        
        let curFrame = curAttributes!.frame
        let stretchedCurFrame = CGRectMake(0, curFrame.origin.y, self.collectionView!.frame.size.width, curFrame.size.height)
        
        if CGRectIntersectsRect(prevFrame, stretchedCurFrame) {
            curAttributes!.frame = CGRectMake(prevFrameRightPoint, curFrame.origin.y, curFrame.size.width, curFrame.size.height)
        } else {
            curAttributes!.frame = CGRectMake(sectionInset.left, curFrame.origin.y, curFrame.size.width, curFrame.size.height)
        }
        
        return curAttributes
    }
}
