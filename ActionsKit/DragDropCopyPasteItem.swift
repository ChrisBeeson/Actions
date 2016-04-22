//
//  DragDropCopyPasteItem.swift
//  Actions
//
//  Created by Chris Beeson on 27/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

protocol DragDropCopyPasteItem {
    
    // Copy & Paste
    
    func pasteboardItem() -> NSPasteboardItem
    
    // Drag & Drop
    
    func isDraggable() -> Bool
    
    func draggingItem() -> NSPasteboardWriting?
    
    func validateDrop(item: NSPasteboardItem, proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation
    
    func acceptDrop(collectionView: NSCollectionView, item: NSPasteboardItem, dropOperation: NSCollectionViewDropOperation) -> Bool
}

extension DragDropCopyPasteItem {
    
    /*
    func dragType(draggingInfo:NSDraggingInfo) -> String {
        
        let pasteBoard = draggingInfo.draggingPasteboard()
        if pasteBoard.type != nil && pasteBoard.types
        let name = pasteBoard.types[0]
    }
*/
    
    
}

