//
//  NodeDetailViewController.swift
//  Filament
//
//  Created by Chris on 12/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class NodeDetailViewController : NSViewController, NodePresenterDelegate {
    
    
    @IBOutlet weak var tokenField: NSTokenField!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var notesTextField: NSTextField!
    
    
    // StackView Views

    @IBOutlet weak var mainStackView: NSStackView!
    @IBOutlet weak var titleStackView: NSStackView!
    @IBOutlet weak var eventStackView: NSStackView!
    @IBOutlet weak var rulesView: NSBox!
    
    @IBOutlet weak var testStackView: NSStackView!
    
    @IBOutlet var testView: NSView!
    
    
    var nodePresenter: NodePresenter?
    
    override public func viewWillAppear() {
        super.viewWillAppear()
        
        titleTextField.stringValue = nodePresenter!.title
        notesTextField.stringValue = nodePresenter!.notes
        
        // eventStackView.hidden = true
        
                mainStackView.addArrangedSubview(testView)
        
    }
    
    @IBAction func titleTextFieldDidFinishEditing(sender: AnyObject) {
        
        nodePresenter!.title = titleTextField.stringValue
    }
    
    
    @IBAction func calendarLinkButtonPressed(sender: AnyObject) {
        
        // testView.hidden = true
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 1.0
            self.testView.animator().hidden = !self.testView.hidden
            }, completionHandler: nil)

    /*
        testStackView.hidden = true
        
        mainStackView.addArrangedSubview(testStackView)
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 1.0
            self.testStackView.animator().hidden = false
            }, completionHandler: nil)
        
        */
    }
    
    
    /*

    NSAnimationContext.runAnimationGroup({ contextin
    context.duration = 1.0
    self.subviewToHide.animatior().hidden = true
    }, completionHandler: nil)
*/
    
    /*
    public func nodePresenterDidChangeTitle(presenter: NodePresenter) {
        
        titleTextField.stringValue = nodePresenter!.title
    }
    */
    
    //override public func viewWillAppear() {
        
   
        
        // titleTextField.selectable = false
        
        // tokenField.objectValue = ["< 48h","Tomorrow","AvoidAllCals","AvoidLunch"]
    //  }
}