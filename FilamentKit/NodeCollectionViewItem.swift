//
//  NodeCollectionViewItem.swift
//  Filament
//
//  Created by Chris Beeson on 6/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class NodeCollectionViewItem : NSCollectionViewItem, NodePresenterDelegate, SequenceCollectionViewDropDestination, NSPopoverDelegate {
    
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
        
        let detailViewController = NodeDetailViewController(nibName:"NodeDetailViewController", bundle:NSBundle(identifier:"com.andris.FilamentKit"))
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
        
        Swift.print("nodePresenter:\(presenter.title)  DidChangeState:\(toState)")
        
        guard toState != currentState else { Swift.print("Already in that state");return }
        updateView()
        self.nodeView.updateViewToState(toState, shouldTransition:true)
        currentState = toState
        /*
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
    
    
    //MARK: Pasteboard
    
    func draggingItem() -> NSPasteboardItem {
        return presenter!.draggingItem()
    }
    
    
    //MARK: Drag & Drop
    
    func validateDrop(item: NSPasteboardItem, proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        
        switch item.types[0] {
        case AppConfiguration.UTI.rule:
            let rulePresenter =  RulePresenter(draggingItem:item)
            if presenter!.availableRulePresenters().contains(rulePresenter) == true {
                return .Copy
            }
        default:
            return .None
        }
        
        return .None
    }
    
    func acceptDrop(collectionView: NSCollectionView, acceptDrop item: NSPasteboardItem, indexPath: NSIndexPath, dropOperation: NSCollectionViewDropOperation) -> Bool {
        return false
    }
    
    
    
    func nodePresenterDidChangeTitle(presenter: NodePresenter) {
        
        //  self.collectionView.reloadData()
        displayedPopover?.close()
        self.collectionView.animator().reloadItemsAtIndexPaths(Set(arrayLiteral: self.indexPath!))
    }
    
    
    override var acceptsFirstResponder: Bool { return true }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    func popoverDidClose(notification: NSNotification) {
        displayedPopover = nil
    }
}