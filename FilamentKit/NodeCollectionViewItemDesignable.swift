 //
//  NodeCollectionViewItemView.swift
//  Filament
//
//  Created by Chris on 18/04/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

@IBDesignable

class NodeCollectionViewItemDesignable : NSView {
    
    var item : NodeCollectionViewItem?
    var presenter : NodePresenter?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
         sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    func sharedInit() {
        presenter = NodePresenter(node: Node())
        presenter!.title = "Unknown Designable Node"
        presenter!.type = .Action

        item = NodeCollectionViewItem(nibName: "ActionNodeCollectionViewItem", bundle:NSBundle(identifier:"com.andris.FilamentKit"))!

        guard item != nil else {return ; fatalError("CollectionViewItem is Null") }

        item!.presenter = presenter
        
          let itemView = item!.view
        // itemView.setFrameSize(item!.calculatedSize())

          self.addSubview(itemView)

    }
    
    
    override func layout() {
        super.layout()
    }
    
    
    /*
    override func viewWillDraw() {
        super.viewWillDraw()
     
        let itemView = item.view
        // itemView.setFrameSize(item.calculatedSize())
        self.addSubview(itemView)
    }
  */
  
}