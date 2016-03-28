//
//  SequenceCollectionViewDropDestination.swift
//  Filament
//
//  Created by Chris Beeson on 27/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

protocol SequenceCollectionViewDropDestination {
    
    func validateDrop(item: NSPasteboardItem, proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation
    func acceptDrop(collectionView: NSCollectionView, acceptDrop item: NSPasteboardItem, indexPath: NSIndexPath, dropOperation: NSCollectionViewDropOperation) -> Bool
}

extension SequenceCollectionViewDropDestination {
    
    /*
    func dragType(draggingInfo:NSDraggingInfo) -> String {
        
        let pasteBoard = draggingInfo.draggingPasteboard()
        if pasteBoard.type != nil && pasteBoard.types
        let name = pasteBoard.types[0]
    }
*/
    
    
}

