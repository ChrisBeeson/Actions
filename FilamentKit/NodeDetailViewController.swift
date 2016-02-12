//
//  NodeDetailViewController.swift
//  Filament
//
//  Created by Chris on 12/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class NodeDetailViewController : NSViewController, NodePresenterDelegate {
    
    @IBOutlet weak var stackView: NSStackView!
    @IBOutlet weak var tokenField: NSTokenField!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var notesTextField: NSTextField!
    
    
    // StackView Views
    @IBOutlet weak var titleView: NSView!
    @IBOutlet weak var sceduledDateView: NSView!
    @IBOutlet weak var rulesView: NSBox!
    
    
    var nodePresenter: NodePresenter?
    
    override public func viewWillAppear() {
        super.viewWillAppear()
        
        titleTextField.stringValue = nodePresenter!.title
        notesTextField.stringValue = nodePresenter!.notes
    }
    
    @IBAction func titleTextFieldDidFinishEditing(sender: AnyObject) {
        
        nodePresenter!.title = titleTextField.stringValue
    }
    
    
    /*
    public func nodePresenterDidChangeTitle(presenter: NodePresenter) {
        
        titleTextField.stringValue = nodePresenter!.title
    }
    */
    
    override public func viewDidAppear() {
        
        
        // stackView.removeArrangedSubview(sceduledDateView)
        
        // titleTextField.selectable = false
        
        // tokenField.objectValue = ["< 48h","Tomorrow","AvoidAllCals","AvoidLunch"]
    }
}