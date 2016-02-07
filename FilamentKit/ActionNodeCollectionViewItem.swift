//
//  ActionNodeCollectionViewItem.swift
//  Filament
//
//  Created by Chris Beeson on 6/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class ActionNodeCollectionViewItem : NSCollectionViewItem {
 
    convenience init(node : Node) {
        
        self.init()
        self.representedObject = node
    }
    
    override func loadView() {
        
        assert(self.representedObject != nil)
        
        view = ActionNodeView(node: representedObject as! Node)
        
        // self.view = NSView(frame:CGRect(origin: CGPoint(x: 100, y: 100), size: CGSize(width: 100, height: 100)))
    }
    
    override func viewDidLoad() {
        
    }
}