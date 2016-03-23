//
//  NodeCollectionViewItem.swift
//  Filament
//
//  Created by Chris Beeson on 6/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class NodeCollectionViewItem : NSCollectionViewItem, NodePresenterDelegate {
    
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var nodeView: NodeView!
    
    @IBOutlet weak var statusField: NSTextField?
    @IBOutlet weak var statusFieldBackground: NSTextField?
    
    
    var indexPath : NSIndexPath?

    var presenter: NodePresenter?  {
        
        didSet {
            presenter?.addDelegate(self)
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
        presenter!.updateNodeState()
        updateView()
    }
    
    
    func updateView() {
        guard presenter != nil else { Swift.print("Presenter for Node Collection View is NULL"); return }
        
        titleTextField.stringValue = presenter!.title
        nodeView.currentState = presenter!.currentState
  
        let hidden = presenter!.currentState == .Completed ? false : true
        statusField?.hidden = hidden
        statusFieldBackground?.hidden = hidden
    }
    
    
    override func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
        
        if theEvent.clickCount < 2 {return }
        
        let popover = NSPopover()
        popover.animates = true
        popover.behavior = .Semitransient
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        
        let detailViewController = NodeDetailViewController(nibName:"NodeDetailViewController", bundle:NSBundle(identifier:"com.andris.FilamentKit"))
        detailViewController!.nodePresenter = presenter!
        presenter!.addDelegate(detailViewController!)
        
        popover.contentViewController = detailViewController
        
        // Popover position & show
        
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
    
        updateView()
        
        switch toState {
            
        case .Ready :
            
            if let indexPath = indexPath {
                
                delay(Double(indexPath.item) * 0.1) {
                    self.nodeView.currentState = .Ready
                }} else {
                self.nodeView.currentState = .Ready
            }
            
        default:
             self.nodeView.currentState = toState
        }
    }
    
    
    func nodePresenterDidChangeTitle(presenter: NodePresenter) {
        
        self.collectionView.reloadData()
        //  self.collectionView.reloadItemsAtIndexPaths(Set(arrayLiteral: self.indexPath!))
    }
    
    
    override var acceptsFirstResponder: Bool { return true }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
}




