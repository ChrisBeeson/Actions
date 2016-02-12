//
//  NodeDetailViewController.swift
//  Filament
//
//  Created by Chris on 12/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class NodeDetailViewController : NSViewController {
    
    @IBOutlet weak var tokenField: NSTokenField!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var notesTextField: NSTextField!
    
    
    override public func viewDidAppear() {
        
        tokenField.objectValue = ["< 48h","Tomorrow","AvoidAllCals","AvoidLunch"]
    }
}