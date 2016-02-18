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
            
            nodeView.currentColour = .LightGrey
            
            switch presenter!.currentStatus {
            case .inActive:break
            case .Ready: break
            case .Running:break
            case .Completed:break
            case .WaitingForUserInput:break
            case .Error:break
            case .Void:break
            }
        }
    }
    
    
    override func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
        
        
        if theEvent.clickCount == 1 {
            
            // test animation
            
            nodeView.pathLayer.fillColor = AppConfiguration.Palette.blueFill.CGColor
            nodeView.pathLayer.strokeColor = AppConfiguration.Palette.blueOutline .CGColor
            return
        }
        
        // if theEvent.clickCount < 2 {return }
        
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
    
    func nodePresenterDidChangeTitle(presenter: NodePresenter) {
        
        titleTextField.stringValue = presenter.title
        self.collectionView.reloadData()
    }
    
    
    override var acceptsFirstResponder: Bool { return true }
    
    override func becomeFirstResponder() -> Bool {
        
        return true
    }
    
}