//
//  AddNewNodeCollectionViewItem.swift
//  Filament
//
//  Created by Chris on 10/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class AddNewNodeCollectionViewItem : NSCollectionViewItem {
    
    @IBOutlet weak var plusButton: NSButton!
    
    
    override func viewDidLoad() {
        
        let tracking = NSTrackingArea(rect: self.view.frame, options: [.MouseEnteredAndExited,.ActiveInActiveApp] , owner: self, userInfo: nil)
        self.view.addTrackingArea(tracking)
         plusButton.alphaValue = 0.0
    }
    
    
    
    
    @IBAction func plusButtonPressed(sender: AnyObject) {
        

    }
    

    
     override func mouseEntered(theEvent: NSEvent) {

        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration  = 0.5
        plusButton.animator().alphaValue = 1.0
        NSAnimationContext.endGrouping()
    }
    
    override func mouseExited(theEvent: NSEvent) {
        
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration  = 0.5
        plusButton.animator().alphaValue = 0.0
        NSAnimationContext.endGrouping()
    }
    
}

