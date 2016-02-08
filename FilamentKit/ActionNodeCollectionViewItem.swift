//
//  ActionNodeCollectionViewItem.swift
//  Filament
//
//  Created by Chris Beeson on 6/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class ActionNodeCollectionViewItem : NSCollectionViewItem {
    
    @IBOutlet weak var nodeTitleTextField: AutoSizingTextField!
    
    var node: Node? {
        didSet {
          nodeTitleTextField.stringValue = node!.title
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
}