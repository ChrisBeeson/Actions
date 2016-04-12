//
//  SequenceCollectionView.swift
//  Filament
//
//  Created by Chris on 5/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import Async

public enum SequenceCollectionViewLayoutState {
    case StartDateWithAddButton
    case StartDateWithoutAddButton
    case EndDateWithAddButton
    case EndDateWithoutAddButton
}

public enum SequenceCollectionViewItemType {
    case Date
    case ActionNode
    case TransitionNode
    case AddButton
    case Void
}

public enum SequenceCollectionViewDraggingState {
    case IsDraggingNode
}

public class SequenceCollectionView : NSCollectionView, NSCollectionViewDataSource, NSCollectionViewDelegate, SequencePresenterDelegate {
    
    public var currentLayoutState = SequenceCollectionViewLayoutState.StartDateWithAddButton
    
    public weak var presenter : SequencePresenter? {
        didSet {
            presenter?.addDelegate(self)
            calculateLayoutState()
        }
    }
    
    private var dragDropInPlaceView:NSView?
    var currentlyDraggingIndexPath: NSIndexPath?
    
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
        self.allowsMultipleSelection = false
        dragDropInPlaceView?.removeFromSuperview()
        dragDropInPlaceView = nil
        
        //self.collectionViewLayout = LeftAlignedSequenceFlowLayout()
        //self.wantsLayer = true
        
        let nib = NSNib(nibNamed: "DateNodeCollectionViewItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))
        self.registerNib(nib, forItemWithIdentifier: "DateNodeCollectionViewItem")
        
        let actionNib = NSNib(nibNamed: "ActionNodeCollectionViewItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))
        self.registerNib(actionNib, forItemWithIdentifier: "ActionNodeCollectionViewItem")
        
        let transNib = NSNib(nibNamed: "TransitionNodeCollectionViewItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))
        self.registerNib(transNib, forItemWithIdentifier: "TransitionNodeCollectionViewItem")
        
        let addNib = NSNib(nibNamed: "AddNewNodeCollectionViewItem", bundle: NSBundle(identifier:"com.andris.FilamentKit"))
        self.registerNib(addNib, forItemWithIdentifier: "AddNewNodeCollectionViewItem")
        
        self.registerForDraggedTypes([AppConfiguration.UTI.dateNode, AppConfiguration.UTI.node, AppConfiguration.UTI.rule])
    }
    
    deinit {
        presenter?.removeDelegate(self)
        presenter = nil
    }
    
    
    //MARK: Sequence Delegate Protocol
    
    public func sequencePresenterDidUpdateChainContents(insertedNodes:Set<NSIndexPath>, deletedNodes:Set<NSIndexPath>) {
        
        if insertedNodes.count > 0 {
            self.animator().insertItemsAtIndexPaths(dynamicIndexForNodeIndex(insertedNodes))
            
            Async.main(after: 0.1) {
                self.animator().scrollToItemsAtIndexPaths(self.dynamicIndexForNodeIndex(insertedNodes), scrollPosition: .CenteredHorizontally)
            }
        }
        
        if deletedNodes.count > 0 {
            // Do we need to delete the transition view to the right?
            // We do unless the next index is the addButton.. ie it's the action on the end
            //TODO: Animate Delete Node
            /*
             let type =  itemTypeAtIndex(NSIndexPath(forItem: deletedNodes.first!.item + 1, inSection: 0 ))
             var nodesToDelete = deletedNodes
             if type == SequenceCollectionViewItemType.TransitionNode {
             nodesToDelete.insert(NSIndexPath(forItem: deletedNodes.first!.item + 1, inSection: 0))
             Swift.print("Added Transition Node")
             }
             */
            // self.deleteItemsAtIndexPaths(dynamicIndexForNodeIndex(deletedNodes))
            self.animator().reloadData()
        }
    }
    
    public func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenter ) {
        calculateLayoutState()
        self.animator().reloadData()
    }
    
    public func sequencePresenterDidChangeState(sequencePresenter: SequencePresenter, toState:SequenceState){
    }
    
    
    //MARK: Events
    
    public func copy(event: NSEvent) {
        var items = [NSPasteboardWriting]()
        for indexPath in self.selectionIndexPaths {
            if let object = self.itemAtIndexPath(indexPath) {
                if object.isKindOfClass(NodeCollectionViewItem) {
                    items.append((object as! NodeCollectionViewItem).pasteboardItem())
                    Swift.print("Copied Node")
                }
            }
        }
    }
    
    public func paste(event: NSEvent) {
        Swift.print("paste")
        
        // So whats on the pasteboard!
        if NSPasteboard.generalPasteboard().canReadItemWithDataConformingToTypes([AppConfiguration.UTI.node]) == true {
            Swift.print("paste NODE!")
        }
        
        if NSPasteboard.generalPasteboard().canReadItemWithDataConformingToTypes([AppConfiguration.UTI.rule]) == true {
            Swift.print("paste RULE!")
        }
    }
    
    
    public func delete(theEvent: NSEvent) {
        var nodesToDelete = [Node]()
        for indexPath in self.selectionIndexPaths {
            if let object = self.itemAtIndexPath(indexPath) {
                if object.isKindOfClass(NodeCollectionViewItem) {
                    let item = object as! NodeCollectionViewItem
                    if item.presenter!.type == .Action {
                        nodesToDelete.append(item.presenter!.node)
                    }
                }
            }
        }
        presenter?.deleteNodes(nodesToDelete, informDelegates: true)
    }
    
    
    override public func keyDown(theEvent: NSEvent) {
        if theEvent.keyCode == 51 || theEvent.keyCode == 117  {
            delete(theEvent)
        }
    }
    
    
    //MARK: CollectionView Datasource
    
    public func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        switch presenter!.currentState {
        case .Completed:
            return presenter!.nodes!.count + 1
        default:
            return presenter!.nodes!.count + 2
        }
    }
    
    public func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        return itemForIndexPath(indexPath)
    }
    
    public func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> NSSize {
        
        if currentlyDraggingIndexPath != nil && indexPath == currentlyDraggingIndexPath {
            Swift.print("Dragging Path Size")
            return NSSize(width: 0.0, height: 25.0)
            
        }
        return sizeForIndexPath(indexPath)
    }
    
    public func collectionView(collectionView: NSCollectionView, didEndDisplayingItem item: NSCollectionViewItem, forRepresentedObjectAtIndexPath indexPath: NSIndexPath) {
    }
    
    
    //MARK: Collection View Delegate
    
    public func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    public func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    public func collectionView(collectionView: NSCollectionView, willDisplayItem item: NSCollectionViewItem, forRepresentedObjectAtIndexPath indexPath: NSIndexPath) {
        if item.isKindOfClass(NodeCollectionViewItem) == true {
            (item as! NodeCollectionViewItem).indexPath = indexPath
        }
    }
    
    
    //MARK: Drag Drop
    
    public func collectionView(collectionView: NSCollectionView, canDragItemsAtIndexPaths indexPaths: Set<NSIndexPath>, withEvent event: NSEvent) -> Bool {
        
        if indexPaths.count == 0 { return false }
        return (itemForIndexPath(indexPaths.first!) as! DragDropCopyPasteItem).isDraggable()
    }
    
    public func collectionView(collectionView: NSCollectionView, pasteboardWriterForItemAtIndexPath indexPath: NSIndexPath) -> NSPasteboardWriting? {
        
        return (itemForIndexPath(indexPath) as! DragDropCopyPasteItem).draggingItem()
    }
    
    public func collectionView(collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAtPoint screenPoint: NSPoint, forItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
        
        // currentlyDraggingIndexPath = indexPaths.first
        //self.animator().reloadItemsAtIndexPaths(indexPaths)
        
        // This is such a hacky solution!! (But it works!)
        // I wanted to keep the original source view where it is, and the draggingView is an addition.
        
        let item = itemForIndexPath(indexPaths.first!)
        item.selected = false
        dragDropInPlaceView = item.view
        dragDropInPlaceView!.frame = self.frameForItemAtIndex(indexPaths.first!.item)
        self.addSubview(dragDropInPlaceView!)
    }
    
    public func collectionView(collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAtPoint screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
        
        // currentlyDraggingIndexPath = nil
        
        dragDropInPlaceView?.removeFromSuperview()
        dragDropInPlaceView = nil
    }
    
    
    public func collectionView(collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath?>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        
        guard draggingInfo.draggingPasteboard().pasteboardItems != nil && draggingInfo.draggingPasteboard().pasteboardItems!.count == 1 else { Swift.print("pasteboardItems are nil or more than 1") ; return .None }
        
        if proposedDropIndexPath.memory == nil { return .None }
        if let proposedDestinationItem = (itemForIndexPath(proposedDropIndexPath.memory!) as? DragDropCopyPasteItem) {
            
            let result = proposedDestinationItem.validateDrop(draggingInfo.draggingPasteboard().pasteboardItems![0], proposedDropOperation:proposedDropOperation)
            
            return result
        }
        return .None
    }
    
    
    public func collectionView(collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: NSIndexPath, dropOperation: NSCollectionViewDropOperation) -> Bool {
        
        let destItem = itemForIndexPath(indexPath)
        guard let pasteBoardItems = draggingInfo.draggingPasteboard().pasteboardItems else { Swift.print ("Nil Pasteboard items") ; return false }
        
        // something other than a node is being dropped
        if pasteBoardItems[0].types[0] != AppConfiguration.UTI.node {
            return (destItem as! DragDropCopyPasteItem).acceptDrop(collectionView, item:pasteBoardItems[0], dropOperation:dropOperation)
        }
        
        // A node is being dropped onto a node
        let sourceNodeItem = NodePresenter(pasteboardItem:pasteBoardItems[0]) //Item being dragged - the from - and must be an ActionNode
        guard let sourceModelIndex = self.presenter!.sequence.actionNodes.indexOf(sourceNodeItem.node) else { Swift.print ("Failed") ; return false }
        
        switch destItem {
        case is NodeCollectionViewItem:
            
            let toIndex = actionNodeIndexForPath(indexPath)!
            presenter?.moveNode(sourceModelIndex, toActionNodesIndex: toIndex)
            //self.reloadData()
            //self.needsLayout = true
            return true
            
            // guard var sourceCollectionViewIndex = self.presenter!.sequence.nodeChain().indexOf(sourceNodeItem.node) else { Swift.print ("Failed") ; return false }
            //sourceCollectionViewIndex += 1
            //let sourceCollectionViewIndexPath = NSIndexPath(forItem: sourceCollectionViewIndex, inSection: 0)
            //  Swift.print("from:\(ip) to:\(indexPath)")
            // self.moveItemAtIndexPath(sourceCollectionViewIndexPath, toIndexPath: indexPath)
            
        case is AddNewNodeCollectionViewItem:
            let toIndex = presenter?.timeDirection == .Forward ? presenter!.nodes!.count - 1 : 0
            presenter?.moveNode(sourceModelIndex, toActionNodesIndex:toIndex)
            //self.reloadData()
            //self.needsLayout = true
            return true
            
        case is DateNodeCollectionViewItem:
            let toIndex = presenter?.timeDirection == .Forward ?  0 : presenter!.nodes!.count - 1
            presenter?.moveNode(sourceModelIndex, toActionNodesIndex:toIndex)
            //self.reloadData()
            //self.needsLayout = true
            return true
        default: return false
        }
    }
    
    
    public func collectionView(collectionView: NSCollectionView, shouldChangeItemsAtIndexPaths indexPaths: Set<NSIndexPath>, toHighlightState highlightState: NSCollectionViewItemHighlightState) -> Set<NSIndexPath> {
        return indexPaths
    }
    
    public func collectionView(collectionView: NSCollectionView, didChangeItemsAtIndexPaths indexPaths: Set<NSIndexPath>, toHighlightState highlightState: NSCollectionViewItemHighlightState) {
    }
    
    
    // Selection
    
    public func collectionView(collectionView: NSCollectionView, shouldSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) -> Set<NSIndexPath> {
        return indexPaths
    }
    
    public func collectionView(collectionView: NSCollectionView, didSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
        self.window?.makeFirstResponder(self)
    }
    
    public func collectionView(collectionView: NSCollectionView, shouldDeselectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) -> Set<NSIndexPath> {
        return indexPaths
    }
    
    public func collectionView(collectionView: NSCollectionView, didDeselectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
        self.window?.makeFirstResponder(self.superview?.superview?.superview?.superview?.superview?.superview)
    }
    
    
    public func collectionView(collectionView: NSCollectionView, willDisplaySupplementaryView view: NSView, forElementKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
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