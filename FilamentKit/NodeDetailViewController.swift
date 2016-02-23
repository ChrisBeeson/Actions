//
//  NodeDetailViewController.swift
//  Filament
//
//  Created by Chris on 12/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class NodeDetailViewController : NSViewController, NodePresenterDelegate {
    
    @IBOutlet weak var tokenField: RuleTokenField!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var notesTextField: NSTextField!
    @IBOutlet weak var dateTextField: NSTextField!
    
    // StackView Views
    @IBOutlet weak var mainStackView: NSStackView!
    @IBOutlet weak var titleStackView: NSStackView!
    @IBOutlet weak var eventStackView: NSStackView!
    @IBOutlet weak var rulesView: NSBox!
    @IBOutlet weak var testStackView: NSStackView!
    @IBOutlet var testView: NSView!
    @IBOutlet weak var testStack: NSStackView!
    
    var nodePresenter: NodePresenter?
    
    
    override public func viewDidLoad() {
        
        tokenField.nodePresenter = nodePresenter!
        nodePresenter!.addDelegate(tokenField)
    }
    
    
    
    override public func viewWillAppear() {
        super.viewWillAppear()
        
        titleTextField.stringValue = nodePresenter!.title
        notesTextField.stringValue = nodePresenter!.notes

      /*
        if nodePresenter!.type == NodeType.Action {
            if let date = nodePresenter!.event?.startDate {
                dateTextField.stringValue = date.formattedDateWithStyle(.LongStyle)
            } else {
                dateTextField.stringValue = ""
            }
        } else {
             dateTextField.stringValue = ""
        }
*/
    }
    

    
    
    
    @IBAction func titleTextFieldDidFinishEditing(sender: AnyObject) {
        
        nodePresenter!.title = titleTextField.stringValue
    }
    
    
    @IBAction func calendarLinkButtonPressed(sender: AnyObject) {
        
         mainStackView.animator().addArrangedSubview(testStack)
        
        // titleTextField.selectable = false
}
}