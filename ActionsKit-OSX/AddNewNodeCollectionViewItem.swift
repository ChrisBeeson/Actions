//
//  AddNewNodeCollectionViewItem.swift
//  Actions
//
//  Created by Chris on 10/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import AppKit

public class AddNewNodeCollectionViewItem : NSCollectionViewItem, DragDropCopyPasteItem {
    
    @IBOutlet weak var plusButton: NSButton!
    
    weak var sequencePresenter : SequencePresenter?
    
    override public func viewDidLoad() {
        let tracking = NSTrackingArea(rect: self.view.frame, options: [.MouseEnteredAndExited,.ActiveInActiveApp] , owner: self, userInfo: nil)
        self.view.addTrackingArea(tracking)
         plusButton.alphaValue = 0.0
    }
    
    @IBAction func plusButtonPressed(sender: AnyObject) {
        sequencePresenter?.insertActionNode(nil, actionNodesIndex: nil, informDelegates:true)
    }
    
     override public func mouseEntered(theEvent: NSEvent) {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration  = 0.4
        plusButton.animator().alphaValue = 1.0
        NSAnimationContext.endGrouping()
    }
    
    override public func mouseExited(theEvent: NSEvent) {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration  = 0.4
        plusButton.animator().alphaValue = 0.0
        NSAnimationContext.endGrouping()
    }
    
    //MARK: Drag & Drop
    
    func pasteboardItem() -> NSPasteboardItem {
        fatalError("You cannot copy the add button")
    }
    
    func isDraggable() -> Bool {
     return false
    }
    
    func draggingItem() -> NSPasteboardWriting? {
        return nil
    }
    
    func validateDrop(item: NSPasteboardItem, proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        
        if item.types[0] == AppConfiguration.UTI.node {
            return .Copy
        } else  {
           return .None
        }
    }
    
    func acceptDrop(collectionView: NSCollectionView, item: NSPasteboardItem, dropOperation: NSCollectionViewDropOperation) -> Bool {
        return false
    }
}

