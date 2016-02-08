//
//  TransitionNodeCollectionViewItem.swift
//  Filament
//
//  Created by Chris Beeson on 7/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class TransitionNodeCollectionViewItem : NSCollectionViewItem {
    
    convenience init(node : Node) {
        
        self.init()
        self.representedObject = node
    }
    
    override func loadView() {
        
        assert(self.representedObject != nil)
        view = TransitionNodeView(node: representedObject as! Node)
    }
    
    override func viewDidLoad() {
        
    }
}
