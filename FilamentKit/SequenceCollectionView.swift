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
        
            /*
             Cant get the animation to work correctly
             
            let type =  itemTypeAtIndex(NSIndexPath(forItem: deletedNodes.first!.item + 1, inSection: 0 ))
            var nodesToDelete = deletedNodes
            if type == SequenceCollectionViewItemType.TransitionNode {
                nodesToDelete.insert(NSIndexPath(forItem: deletedNodes.first!.item + 1, inSection: 0))
                Swift.print("Added Transition Node")
            }
            */
            //  self.deleteItemsAtIndexPaths(dynamicIndexForNodeIndex(deletedNodes)
            self.reloadData()
        }
    }
    
    public func sequencePresenterDidChangeState(sequencePresenter: SequencePresenter, toState:SequenceState){
        calculateLayoutState()
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
                    if item.presenter!.type == .Action {
                        nodesToDelete.append(item.presenter!.node)
                    }
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
        
        return itemForIndexPath(indexPath)!
    }
    
    public func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> NSSize {
        
        if currentlyDraggingIndexPath != nil && indexPath == currentlyDraggingIndexPath {
            return NSSize(width: 0.0, height: 25.0)
        }
        
        return sizeForIndexPath(indexPath)
    }
    
    
    public func collectionView(collectionView: NSCollectionView, didEndDisplayingItem item: NSCollectionViewItem, forRepresentedObjectAtIndexPath indexPath: NSIndexPath) {
        /*
         if item.isKindOfClass(NodeCollectionViewItem) {
         (item as! NodeCollectionViewItem).presenter = nil
         }
         */
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
            // (item as! NodeCollectionViewItem).updateView()
            (item as! NodeCollectionViewItem).indexPath = indexPath
        }
    }
    
    //MARK: Drag Drop
    
    public func collectionView(collectionView: NSCollectionView, canDragItemsAtIndexPaths indexPaths: Set<NSIndexPath>, withEvent event: NSEvent) -> Bool {
        if indexPaths.count == 0 { return false }
        
        // We can drag anything but completed items, transitions or the addButton
        if itemTypeAtIndex(indexPaths.first!) == .AddButton { return false }
        if itemTypeAtIndex(indexPaths.first!) == .Date { return false }
        if let item = itemForIndexPath(indexPaths.first!) {
            if item.isKindOfClass(NodeCollectionViewItem) {
                if let presenter = (item as! NodeCollectionViewItem).presenter {
                    if presenter.type == .Transition { return false }
                    if presenter.currentState == .Running { return false }
                    if presenter.currentState == .Completed { return false }
                }
            }
        }
        return true
    }
    
    public func collectionView(collectionView: NSCollectionView, pasteboardWriterForItemAtIndexPath indexPath: NSIndexPath) -> NSPasteboardWriting? {
        
        if  let item = itemForIndexPath(indexPath) {
            if item.isKindOfClass(DateNodeCollectionViewItem) { return (item as! DateNodeCollectionViewItem).draggingItem() }
            if item.isKindOfClass(NodeCollectionViewItem) { return (item as! NodeCollectionViewItem).draggingItem() }
        }
        Swift.print("Returning Nil")
        return nil
    }
    
    public func collectionView(collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAtPoint screenPoint: NSPoint, forItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
        
        // currentlyDraggingIndexPath = indexPaths.first
        //self.animator().reloadItemsAtIndexPaths(indexPaths)
        
        // This is such a hacky solution!! (But it works!)
        // I wanted to keep the original source view where it is, and the draggingView is an addition.
        
         if let item = itemForIndexPath(indexPaths.first!) {
         item.selected = false
         dragDropInPlaceView = item.view
         dragDropInPlaceView!.frame = self.frameForItemAtIndex(indexPaths.first!.item)
         self.addSubview(dragDropInPlaceView!)
         }
        
    }
    
    public func collectionView(collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAtPoint screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
        
        // currentlyDraggingIndexPath = nil
        
         dragDropInPlaceView?.removeFromSuperview()
         dragDropInPlaceView = nil
        
    }
    
    
    public func collectionView(collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath?>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        
        var type:String?
        
        // Painfully extract what we are validating
        draggingInfo.enumerateDraggingItemsWithOptions([], forView: self, classes: [NSPasteboardItem.self], searchOptions: [NSPasteboardURLReadingFileURLsOnlyKey: false]) {draggingItem, idx, stop in
            let types = (draggingItem.item as! NSPasteboardItem).types
            if types.count > 0 {
                type = types[0]
            }
        }
        guard type != nil else { return .None }
        
        switch type! {
            
        case AppConfiguration.UTI.rule:
            if proposedDropOperation.memory == .Before { return .None }
            let type =  itemTypeAtIndex(proposedDropIndexPath.memory!)
            if type == .Date  { return .None }
            if type == .AddButton { return .None }
            let item = (itemForIndexPath(proposedDropIndexPath.memory!) as! NodeCollectionViewItem)
            if item.currentState == .Running { return .None }
            if item.currentState == .Completed { return .None }
            //TODO: Valid Rule is aval for Type and that it doesn't already have it - I think we'll need to ask the presenter.
            //return item.presenter.acceptRuleDrop()
            
            return .Copy
            
        case AppConfiguration.UTI.dateNode:
            if collectionView != self {
                // it's from another collection view
                // so either they can drop it on the location of our date, or on the addbutton basically
                if proposedDropOperation.memory == .Before { return .None }
                if indexOfItemType(.Date) == proposedDropIndexPath.memory! { return .Copy }
                // if indexOfItemType(.AddButton) == proposedDropIndexPath.memory! { return .Copy }
            } else {
                //  if proposedDropOperation.memory == .On { return .None }
                if indexOfItemType(.AddButton) == proposedDropIndexPath.memory! { return .Copy }
            }
            
        case AppConfiguration.UTI.node:
/*
             There are only two drag options for a node drop.
             
             1. It can be dropped into another sequence.
                It is just inserted on to the end.
             2. If it is hovering over a transition, which it is not related to, then the transition will open to it's size.  and it's source will disappear.
*/
            
            
            if proposedDropOperation.memory == .Before { return .None }
            let type =  itemTypeAtIndex(proposedDropIndexPath.memory!)
            if type == .Date  { return .None }
            if type == .AddButton { return .None }
            if let item = (itemForIndexPath(proposedDropIndexPath.memory!) as? NodeCollectionViewItem) {
                if item.currentState == .Running { return .None }
                if item.currentState == .Completed { return .None }
                return .Copy
            }
            
        default: break
        }
        return .None
    }
    
    
    public func collectionView(collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: NSIndexPath, dropOperation: NSCollectionViewDropOperation) -> Bool {
        var type:String?
        
        draggingInfo.enumerateDraggingItemsWithOptions([], forView: self, classes: [NSPasteboardItem.self], searchOptions: [NSPasteboardURLReadingFileURLsOnlyKey: false]) {draggingItem, idx, stop in
            let types = (draggingItem.item as! NSPasteboardItem).types
            if types.count > 0 {
                type = types[0]
            }
        }
    
        Swift.print("Accepted Drop: \(indexPath)")
        
        return true
        /*
         if let presenter = rulePresenterFromDraggingItem(draggingInfo) {
         self.ruleCollectionViewDelegate?.didAcceptDrop(self, droppedRulePresenter: presenter, atIndex:indexPath.item)
         return true
         }
         return false
         */
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
    
    //MARK: Dynamic DataSource
    
    func calculateLayoutState() {
        guard presenter != nil else { return }
        
        switch (presenter!.dateIsStartDate) {
        case true:
            if presenter!.currentState == .Completed { currentLayoutState = .StartDateWithoutAddButton } else {currentLayoutState = .StartDateWithAddButton }
        case false:
            if presenter!.currentState == .Completed { currentLayoutState = .EndDateWithoutAddButton } else {currentLayoutState = .EndDateWithAddButton }
        }
    }
    
    func dynamicIndexForNodeIndex(indexPaths:Set<NSIndexPath>) ->  Set<NSIndexPath>{
        var set = Set<NSIndexPath>(minimumCapacity: indexPaths.count)
        let modifier = currentLayoutState == .EndDateWithoutAddButton ? 0 : 1
        for path in indexPaths {
            set.insert(NSIndexPath(forItem: path.item + modifier, inSection: 0))
        }
        return set
    }
    
    func nodeIndexForDynamicIndex(indexPaths:Set<NSIndexPath>) -> Set<NSIndexPath> {
        var set = Set<NSIndexPath>(minimumCapacity: indexPaths.count)
        let modifier = currentLayoutState == .EndDateWithoutAddButton ? 0 : 1
        for path in indexPaths {
            set.insert(NSIndexPath(forItem: path.item - modifier, inSection: 0))
        }
        return set
    }
    
    
    func itemForIndexPath(path: NSIndexPath) -> NSCollectionViewItem? {
        //  Swift.print("Index Path: \(path.item)  item:\(itemTypeAtIndex(path))")
        
        switch itemTypeAtIndex(path) {
        case .Date: return makeDateItem(path)
        case .AddButton: return makeAddButton(path)
        case .ActionNode,.TransitionNode: return makeMainTypeNode(path, type:itemTypeAtIndex(path))
        case .Void: return nil
        }
    }
    
    func sizeForIndexPath(path: NSIndexPath) -> NSSize {
        let modifier = currentLayoutState == .EndDateWithoutAddButton ? 0 : 1
        let nodeIndex = path.item - modifier
        
        switch itemTypeAtIndex(path) {
        case .Date: return NSSize(width: 60,height: 35)
        case .AddButton: return NSSize(width: 30,height: 25)
        case .ActionNode:
            if nodeIndex >= presenter!.nodes!.count {
                Swift.print("Index out of bounds \(nodeIndex) count:\(presenter!.nodes!.count)")
                return NSSize.zero
            }
            let node = presenter!.nodes![path.item - modifier]
            let string:NSString = node.title as NSString
            let textSize: CGSize = string.sizeWithAttributes([NSFontAttributeName: NSFont.systemFontOfSize(14.0, weight:NSFontWeightThin) ])
            return NSSize(width: textSize.width + 30.4, height: 35)
            
        case  .TransitionNode:
            if nodeIndex >= presenter!.nodes!.count {
                Swift.print("Index out of bounds \(nodeIndex) count:\(presenter!.nodes!.count)")
                return NSSize.zero
            }
            let node = presenter!.nodes![path.item - modifier]
            let string:NSString = node.title as NSString
            let textSize: CGSize = string.sizeWithAttributes([NSFontAttributeName: NSFont.systemFontOfSize(9, weight:NSFontWeightRegular) ])
            return NSSize(width:textSize.width + 40, height: 24)
        case .Void: fatalError()
        }
    }
    
    
    func makeDateItem(path: NSIndexPath) -> NSCollectionViewItem {
        let item = makeItemWithIdentifier("DateNodeCollectionViewItem", forIndexPath: path) as! DateNodeCollectionViewItem
        item.sequencePresenter = self.presenter!
        presenter?.addDelegate(item)
        item.updateView()
        return item
    }
    
    func makeAddButton(path: NSIndexPath) -> NSCollectionViewItem {
        let item = makeItemWithIdentifier("AddNewNodeCollectionViewItem", forIndexPath: path) as! AddNewNodeCollectionViewItem
        item.sequencePresenter = presenter
        return item
    }
    
    func makeMainTypeNode(path: NSIndexPath, type:SequenceCollectionViewItemType ) -> NSCollectionViewItem {
        var item: NodeCollectionViewItem
        let modifier = currentLayoutState == .EndDateWithoutAddButton ? 0 : 1
        let node = presenter!.nodes![path.item - modifier]
        
        switch type {
        case .ActionNode:
            item = makeItemWithIdentifier("ActionNodeCollectionViewItem", forIndexPath: path) as! NodeCollectionViewItem
            
        case .TransitionNode:
            item = makeItemWithIdentifier("TransitionNodeCollectionViewItem", forIndexPath: path) as! NodeCollectionViewItem
            
        default: item = NodeCollectionViewItem()
        }
        if item.presenter != presenter!.presenterForNode(node) {
            item.presenter = presenter!.presenterForNode(node)
        }
        item.indexPath = path
        return item
    }
    
    
    func indexOfItemType(itemType: SequenceCollectionViewItemType) -> [NSIndexPath] {
        guard presenter != nil else { fatalError() }
        guard presenter!.nodes != nil else { fatalError() }
        
        switch itemType {
        case .ActionNode:
            var paths = [NSIndexPath]()
            for (index, node) in presenter!.nodes!.enumerate() {
                if node.type == .Action {
                    paths.append(NSIndexPath(index: index+1))
                }
            }
            return paths
            
        case .TransitionNode:
            var paths = [NSIndexPath]()
            for (index, node) in presenter!.nodes!.enumerate() {
                if node.type == .Transition {
                    paths.append(NSIndexPath(index: index+1))
                }
            }
            return paths
            
        case .Date:
            switch self.currentLayoutState {
            case .StartDateWithAddButton, .StartDateWithoutAddButton:
                return [NSIndexPath(index: 0)]
                
            case .EndDateWithAddButton:
                return [NSIndexPath(index: presenter!.nodes!.count+2)]
                
            case .EndDateWithoutAddButton:
                return [NSIndexPath(index: presenter!.nodes!.count+1)]
            }
            
        case .AddButton:
            switch currentLayoutState {
            case .StartDateWithAddButton: return [NSIndexPath(index: presenter!.nodes!.count+2)]
            case .StartDateWithoutAddButton: return [NSIndexPath(index: -1)]
            case .EndDateWithAddButton: return [NSIndexPath(index: 0)]
            case .EndDateWithoutAddButton: return [NSIndexPath(index: -1)]
            }
            
        default: return [NSIndexPath(index: -1)]
        }
    }
    
    
    func itemTypeAtIndex(index:NSIndexPath) -> SequenceCollectionViewItemType {
        switch index.item {
        case 0:
            switch currentLayoutState {
            case .StartDateWithAddButton: return .Date
            case .StartDateWithoutAddButton: return .Date
            case .EndDateWithAddButton: return .AddButton
            case .EndDateWithoutAddButton: return .ActionNode
            }
            
        case presenter!.nodes!.count+1:
            switch currentLayoutState {
            case .StartDateWithAddButton: return .AddButton
            case .StartDateWithoutAddButton: return .Void
            case .EndDateWithAddButton: return .Date
            case .EndDateWithoutAddButton: return .Void
            }
            
        case presenter!.nodes!.count:
            switch currentLayoutState {
            case .StartDateWithAddButton: return .ActionNode
            case .StartDateWithoutAddButton: return .ActionNode
            case .EndDateWithAddButton: return .ActionNode
            case .EndDateWithoutAddButton: return .TransitionNode
            }
            
        case let x where x > 0 && x < presenter!.nodes!.count:
            let modifier = currentLayoutState == .EndDateWithoutAddButton ? 0 : 1
            if (x - modifier) > -1 && (x - modifier) < presenter!.nodes!.count {
                let node = presenter!.nodes![index.item - modifier]
                if node.type == .Action { return .ActionNode } else { return .TransitionNode }
            } else { return .Void }
            
        default: Swift.print("Got to default - Index: \(index.item)")
        }
        return .Void
    }
}