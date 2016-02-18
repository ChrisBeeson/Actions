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
            refreshView()
        }
    }
    
    
    override var selected: Bool {
        didSet {
            nodeView.selected = self.selected
        }
    }
    
    
    override func viewWillAppear() {

    }
    
    func refreshView() {
        
        if presenter != nil {
            titleTextField.stringValue = presenter!.title
            nodeView.currentStatus = .inActive
        }
    }
    
    
    override func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
        
        if theEvent.clickCount < 2 {return }
        
        if popover == nil {
            
            popover = NSPopover()
            popover!.animates = true
            popover!.behavior = .Transient
            popover!.appearance = NSAppearance(named: NSAppearanceNameAqua)
            
            if detailViewController == nil {
                detailViewController = NodeDetailViewController(nibName:"NodeDetailViewController", bundle:NSBundle(identifier:"com.andris.FilamentKit"))
            }
            
            detailViewController!.nodePresenter = presenter!
            presenter!.addDelegate(detailViewController!)
    
            popover!.contentViewController = detailViewController
        }
        
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
    
        if toStatus == .Ready {
            
            delay(Double(indexPath!.item) * 0.3) {
                self.nodeView.currentStatus = .Ready
            }
        } else {
             self.nodeView.currentStatus = toStatus
        }
    }
    
    /*
    
    
    NSAnimationContext.runAnimationGroup({ context in
    context.duration = 1.0
    self.testView.animator().hidden = !self.testView.hidden
    }, completionHandler: nil)
    
    */
    
    
    
    func nodePresenterDidChangeTitle(presenter: NodePresenter) {
        
        titleTextField.stringValue = presenter.title
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

