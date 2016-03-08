//
//  RightAlignedCollectionViewFlowLayout.swift
//  Filament
//
//  Created by Chris on 8/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class RightAlignedCollectionViewFlowLayout: NSCollectionViewFlowLayout {
    
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
        // let sectionInset = (self.collectionView?.collectionViewLayout as! NSCollectionViewFlowLayout).sectionInset
 
        if indexPath.item == 0 {
            curAttributes!.rightAlignFrameOnWidth(self.collectionView!.frame.size.width)
            return curAttributes
        }

        let prevIndexPath = NSIndexPath(forItem: indexPath.item-1, inSection: indexPath.section)
        let prevFrame = self.layoutAttributesForItemAtIndexPath(prevIndexPath)!.frame
      
        
        var curFrame = curAttributes!.frame
        let stretchedCurFrame = CGRectMake(0, curFrame.origin.y, self.collectionView!.frame.size.width, curFrame.size.height)
        
        if CGRectIntersectsRect(prevFrame, stretchedCurFrame) {
            curAttributes!.rightAlignFrameOnWidth(self.collectionView!.frame.size.width)
             return curAttributes
        }
        
        let prevFrameLeftPoint = prevFrame.origin.x
        curFrame.origin.x = prevFrameLeftPoint - maximumCellSpacing - curFrame.size.width
        curAttributes!.frame = curFrame

        return curAttributes
    }
}

extension NSCollectionViewLayoutAttributes {
    
    func rightAlignFrameOnWidth(width:CGFloat) {
        var frame = self.frame
        frame.origin.x = width - frame.size.width
        self.frame = frame
    }
    
}