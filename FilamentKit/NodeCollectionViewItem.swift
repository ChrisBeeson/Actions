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

    
    var indexPath : NSIndexPath?
    var popover: NSPopover?
    var detailViewController: NodeDetailViewController?
    
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
        
         refreshView()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }
    
    
    func refreshView() {
        
        if presenter != nil {
            titleTextField.stringValue = presenter!.title
            presenter!.updateNodeStatus()
            nodeView.currentStatus = presenter!.currentStatus
        }
    }
    
    
    override func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
        
        if theEvent.clickCount < 2 {return }
        
        if popover == nil {
            
            popover = NSPopover()
            popover!.animates = true
            popover!.behavior = .Semitransient
            popover!.appearance = NSAppearance(named: NSAppearanceNameAqua)
            
            if detailViewController == nil {
                detailViewController = NodeDetailViewController(nibName:"NodeDetailViewController", bundle:NSBundle(identifier:"com.andris.FilamentKit"))
            }
            
            popover!.contentViewController = detailViewController
        }
        
        detailViewController!.nodePresenter = presenter!
        presenter!.addDelegate(detailViewController!)
        
        // Popover position & show
        
        var frame = self.view.frame
        switch presenter!.type {
        case .Action:
            frame.size = NSSize(width: frame.size.width-10.0, height: frame.size.height)
            popover?.showRelativeToRect(frame, ofView: self.view.superview!, preferredEdge:.MaxX )
        case .Transition:
            frame.size = NSSize(width: frame.size.width-10.0, height: frame.size.height)
            popover?.showRelativeToRect(frame, ofView: self.view.superview!, preferredEdge:.MaxY )
        default: break
        }
    }
    
    
    //Mark: NodePresenter delegate calls
    
    func nodePresenterDidChangeStatus(presenter: NodePresenter, toStatus: NodeStatus) {
    
        guard presenter == self.presenter else { return }
        
        if presenter.type == .Action {
            titleTextField?.textColor = toStatus == .Completed ?  NSColor.lightGrayColor() : NSColor.blackColor()
        }
        
        if toStatus == .Ready {
            
            if let indexPath = indexPath {
        
            delay(Double(indexPath.item) * 0.1) {
                self.nodeView.currentStatus = .Ready
                }} else {
                 self.nodeView.currentStatus = .Ready
            }
        } else {
             self.nodeView.currentStatus = toStatus
        }
    }
    
    
    func nodePresenterDidChangeTitle(presenter: NodePresenter) {
        
        self.collectionView.reloadData()
    }
    
    
    override var acceptsFirstResponder: Bool { return true }
    
    override func becomeFirstResponder() -> Bool {
        
        return true
    }
    

    
}


func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

