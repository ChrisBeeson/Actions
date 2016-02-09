//
//  ActionNodeCollectionViewItem.swift
//  Filament
//
//  Created by Chris Beeson on 6/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class ActionNodeCollectionViewItem : NSCollectionViewItem {
    
    var indexPath : NSIndexPath?
    
    override public var acceptsFirstResponder: Bool { return true }
    
    @IBOutlet weak var nodeTitleTextField: NSTextField!
    @IBOutlet weak var actionNodeView: ActionNodeView!
    
    var node: Node? {
        didSet {
          nodeTitleTextField.stringValue = node!.title
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
    
    
    override public func becomeFirstResponder() -> Bool {
        
        Swift.print("BecomeFirstResponder:ActionNodeCell")
        
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