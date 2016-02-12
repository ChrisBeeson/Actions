//
//  NodeDetailViewController.swift
//  Filament
//
//  Created by Chris on 12/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class NodeDetailViewController : NSViewController {
    
    @IBOutlet weak var stackView: NSStackView!
    @IBOutlet weak var tokenField: NSTokenField!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var notesTextField: NSTextField!
    
    
    // StackView Views
    @IBOutlet weak var titleView: NSView!
    @IBOutlet weak var sceduledDateView: NSView!
    @IBOutlet weak var rulesView: NSBox!
    
    
    
    var node: Node?
    
    override public func viewDidAppear() {
        
        
        // stackView.removeArrangedSubview(sceduledDateView)
        
        titleTextField.selectable = false
        
        // tokenField.objectValue = ["< 48h","Tomorrow","AvoidAllCals","AvoidLunch"]
    }
}