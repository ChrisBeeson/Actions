//
//  NodeCollectionViewItem.swift
//  Actions
//
//  Created by Chris Beeson on 6/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class NodeCollectionViewItem : NSCollectionViewItem, NodePresenterDelegate, DragDropCopyPasteItem, NSPopoverDelegate {
    
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var nodeView: NodeView!
    
    @IBOutlet weak var statusField: NSTextField?             // Show a tick if completed
    @IBOutlet weak var statusFieldBackground: NSTextField?
    
    var currentState = NodeState.Inactive
    var displayedPopover: NSPopover?
    var indexPath : NSIndexPath?
    
    var presenter: NodePresenter?  {
        didSet {
            if presenter != nil {
                presenter!.addDelegate(self)
                presenter!.updateNodeState()
                updateView()
                self.nodeView.updateViewToState(presenter!.currentState, shouldTransition:false)
            }
        }
    }
    
    override var selected: Bool {
        didSet {
            nodeView.selected = self.selected
        }
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }
    
    
    func updateView() {
        guard presenter != nil else { Swift.print("Presenter for Node Collection View is NULL"); return }
        titleTextField.stringValue = presenter!.title
        let hidden = presenter!.currentState == .Completed ? false : true
        statusField?.hidden = hidden
        statusFieldBackground?.hidden = hidden
        nodeView.currentState = presenter!.currentState
        self.view.toolTip = presenter!.statusDescription
    }
    
    
    func calculatedSize() -> NSSize {
        switch presenter!.type {
        case NodeType.Action:
            let string:NSString = presenter!.title as NSString
            let textSize: CGSize = string.sizeWithAttributes([NSFontAttributeName: NSFont.systemFontOfSize(14.0, weight:NSFontWeightThin) ])
            return NSSize(width: textSize.width + 30.4, height: 35)
            
        case  NodeType.Transition:
            let string:NSString = presenter!.title as NSString
            let textSize: CGSize = string.sizeWithAttributes([NSFontAttributeName: NSFont.systemFontOfSize(9, weight:NSFontWeightRegular) ])
            return NSSize(width:textSize.width + 40, height: 24)
            
        default: return NSSize(width: 1, height: 35)
        }
    }
    
    
    override func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
        if theEvent.clickCount < 2 { return }
        if displayedPopover != nil { return }
        
        let popover = NSPopover()
        popover.animates = true
        popover.behavior = .Semitransient
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        popover.delegate = self
        
        let detailViewController = NodeDetailViewController(nibName:"NodeDetailViewController", bundle:NSBundle(identifier:"com.andris.ActionsKit"))
        detailViewController!.nodePresenter = presenter!
        presenter!.addDelegate(detailViewController!)
        popover.contentViewController = detailViewController
        displayedPopover = popover
        
        var frame = self.view.frame
        
        switch presenter!.type {
        case [.Action]:
            frame.size = NSSize(width: frame.size.width-10.0, height: frame.size.height)
            popover.showRelativeToRect(frame, ofView: self.view.superview!, preferredEdge:.MaxX)
            
        case [.Transition]:
            frame.size = NSSize(width: frame.size.width-10.0, height: frame.size.height)
            popover.showRelativeToRect(frame, ofView: self.view.superview!, preferredEdge:.MaxY)
            
        default: break
        }
    }
    
    
    //Mark: NodePresenter delegate calls
    
    func nodePresenterDidChangeState(presenter: NodePresenter, toState: NodeState, options:[String]? ) {
        guard presenter == self.presenter! else { return }
        
        //Swift.print("nodePresenter:\(presenter.title)  DidChangeState:\(toState)")
        // guard toState != currentState else { Swift.print("Already in that state");return }
        updateView()
        self.nodeView.updateViewToState(toState, shouldTransition:true)
        currentState = toState
        /*   Animation
         switch toState {
         case .Ready :
         if let indexPath = self.indexPath {
         delay(Double(indexPath.item) * 0.1) {
         self.nodeView.updateViewToState(toState, shouldTransition:true)
         }} else {
         self.nodeView.updateViewToState(toState, shouldTransition:true)
         }
         default:
         self.nodeView.updateViewToState(toState, shouldTransition:true)
         }
         */
    }
    
    func nodePresenterDidChangeTitle(presenter: NodePresenter) {
        displayedPopover?.close()
        self.collectionView.animator().reloadItemsAtIndexPaths(Set(arrayLiteral: self.indexPath!))
    }
    
    
    //MARK: Pasteboard
    
    func pasteboardItem() -> NSPasteboardItem {
        return presenter!.pasteboardItem()
    }
    
    
    //MARK: Drag & Drop
    
    func isDraggable() -> Bool {
        if presenter!.type == .Transition { return false }
        if presenter!.currentState == .Running { return false }
        if presenter!.currentState == .Completed { return false }
        return true
    }
    
    func draggingItem() -> NSPasteboardWriting? {
        return pasteboardItem()
    }
    
    func validateDrop(item: NSPasteboardItem, proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        switch item.types[0] {
        case AppConfiguration.UTI.rule:
            let rule = RulePresenter(pasteboardItem:item)
            // TODO: Don't allow identical rules to be droped on themselves.  Rules need isEqual using hash of vars.
            return presenter?.wouldAcceptRulePresenter(rule, allowDuplicates:true) == true ? .Copy : .None
        case AppConfiguration.UTI.node:
            let nodeItem = NodePresenter(pasteboardItem: item)
            if nodeItem.node == self.presenter!.node { return .None }
            if nodeItem.node == self.presenter!.node.leftTransitionNode { return .None }
            if nodeItem.node == self.presenter!.node.rightTransitionNode { return .None }
            if presenter!.type == .Transition { return .Copy }
        default:
            return .None
        }
        return .None
    }
    
    func acceptDrop(collectionView: NSCollectionView, item: NSPasteboardItem, dropOperation: NSCollectionViewDropOperation) -> Bool {
        switch item.types[0] {
        case AppConfiguration.UTI.rule:
            let rule =  RulePresenter(pasteboardItem:item)
            presenter?.insertRulePresenter(rule, atIndex: -1)
            return true
            
        case AppConfiguration.UTI.node:
            // This is handled in Sequence Collection view
            return true
            
        default:
            return false
        }
    }
    
    
    //MARK: First Responder
    
    override var acceptsFirstResponder: Bool { return true }
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    //MARK: Popover Delegate
    
    func popoverDidClose(notification: NSNotification) {
        displayedPopover = nil
    }
}