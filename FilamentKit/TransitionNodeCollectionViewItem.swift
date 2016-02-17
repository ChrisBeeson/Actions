//
//  TransitionNodeCollectionViewItem.swift
//  Filament
//
//  Created by Chris Beeson on 7/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

/*
 TODO: Combine this with ActionNodeCollectionViewItem
*/

public class TransitionNodeCollectionViewItem : NSCollectionViewItem, NodePresenterDelegate {
    

    
    @IBOutlet weak var titleTextView: NSTextField!
    
    var indexPath : NSIndexPath?
    var popover: NSPopover?
    var nodeDetailViewController: NodeDetailViewController?
    var nodePresenter: NodePresenter? {
        didSet {
            titleTextView.stringValue = nodePresenter!.title
        }
    }
    
    
    override public var selected: Bool {
        didSet {
            transitionNodeView.selected = self.selected
            titleTextView.textColor =  selected ? AppConfiguration.Palette.selectionBlue : AppConfiguration.Palette.outlineGray
        }
    }

    
    override public func loadView() {
        
        assert(self.representedObject != nil)
        view = TransitionNodeView(node: representedObject as! Node)
    }
    
    override public func viewDidLoad() {
        //   titleTextView.stringValue = nodePresenter!.title
        
    }
    
    override public func mouseDown(theEvent: NSEvent) {
        
        super.mouseDown(theEvent)
        
        if theEvent.clickCount < 2 {return }
        
        // display popOver
        
        if popover == nil {
            
            popover = NSPopover()
            popover!.animates = true
            popover!.behavior = .Transient
            popover!.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
            
            if nodeDetailViewController == nil {
                nodeDetailViewController = NodeDetailViewController(nibName:"NodeDetailViewController", bundle:NSBundle(identifier:"com.andris.FilamentKit"))
            }
            
            nodeDetailViewController!.nodePresenter = nodePresenter!
            nodePresenter!.addDelegate(nodeDetailViewController!)
            
            popover!.contentViewController = nodeDetailViewController
            
        }
        
        var frame = self.view.frame
        frame.size = NSSize(width: frame.size.width-10.0, height: frame.size.height-10.0)
        
        popover?.showRelativeToRect(frame, ofView: self.view.superview!, preferredEdge:.MaxY )
    }
    
    //Mark: NodePresenter delegate calls
    
    public func nodePresenterDidChangeTitle(presenter: NodePresenter) {
        
        titleTextView.stringValue = nodePresenter!.title
        self.collectionView.reloadData()
    }
}
