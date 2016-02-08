//
//  ActionNodeCollectionViewItem.swift
//  Filament
//
//  Created by Chris Beeson on 6/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class ActionNodeCollectionViewItem : NSCollectionViewItem {
    
    var indexPath : NSIndexPath?
    
    @IBOutlet weak var nodeTitleTextField: NSTextField!
    @IBOutlet weak var actionNodeView: ActionNodeView!
    
    var node: Node? {
        didSet {
          nodeTitleTextField.stringValue = node!.title
        }
    }
    
    override var highlightState: NSCollectionViewItemHighlightState {
        didSet {
            Swift.print("highlight state changed \(highlightState.rawValue)")
           
            //self.actionNodeView.selected = self.highlightState == .ForSelection
            
        }
    }

    
    override func viewDidLoad() {
        
    }
    
    override func viewWillLayout() {
        
        
    }
    
    override func viewWillAppear() {
        if node != nil {
            nodeTitleTextField.stringValue = node!.title
        }
    }
   /*
    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutAttributes {
        let layout = NSCollectionViewLayoutAttributes(forItemWithIndexPath: indexPath!)
        layout.size = NSSize(width: 180,height: 35)
        return layout
       
    }
*/
}