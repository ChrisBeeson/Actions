//
//  ActionNodeCollectionViewItem.swift
//  Filament
//
//  Created by Chris Beeson on 6/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class ActionNodeCollectionViewItem : NSCollectionViewItem, NodePresenterDelegate {
    
    override public var acceptsFirstResponder: Bool { return true }
    
    var indexPath : NSIndexPath?
    var popover: NSPopover?
    var nodeDetailViewController: NodeDetailViewController?
    var nodePresenter: NodePresenter?
    
    
    @IBOutlet weak var nodeTitleTextField: NSTextField!
    @IBOutlet weak var actionNodeView: ActionNodeView!
    
    var node: Node? {
        didSet {
          nodePresenter = NodePresenter(node:node!, delegate:self)
          nodeTitleTextField.stringValue = nodePresenter!.title
        }
    }
    
    override public var selected: Bool {
        didSet {
            actionNodeView.selected = self.selected
        }
    }
    
    
    override public func viewWillAppear() {
        if node != nil {
            nodeTitleTextField.stringValue = node!.title
        }
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
        frame.size = NSSize(width: frame.size.width-10.0, height: frame.size.height)
        
        popover?.showRelativeToRect(frame, ofView: self.view.superview!, preferredEdge:.MaxX )
    }
    
    
    //Mark: NodePresenter delegate calls
    
    public func nodePresenterDidChangeTitle(presenter: NodePresenter) {
        
        nodeTitleTextField.stringValue = nodePresenter!.title
        self.collectionView.reloadData()
    }
    
    
    
    override public func becomeFirstResponder() -> Bool {
        return true
    }
    
    

   /*
    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutAttributes {
        let layout = NSCollectionViewLayoutAttributes(forItemWithIndexPath: indexPath!)
        layout.size = NSSize(width: 180,height: 35)
        return layout
       
    }
*/
}