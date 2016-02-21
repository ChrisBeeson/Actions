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
    @IBOutlet weak var dateTextField: NSTextField!
    
    
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
        

        
        if nodePresenter!.type == NodeType.Action {
            if let date = nodePresenter!.event?.startDate {
                dateTextField.stringValue = date.formattedDateWithStyle(.LongStyle)
            } else {
                dateTextField.stringValue = ""
            }
        } else {
             dateTextField.stringValue = ""
        }
        
        // eventStackView.hidden = true
        
                mainStackView.addArrangedSubview(testView)
        
    }
    
    @IBAction func titleTextFieldDidFinishEditing(sender: AnyObject) {
        
        nodePresenter!.title = titleTextField.stringValue
    }
    
    
    @IBAction func calendarLinkButtonPressed(sender: AnyObject) {
        
        /*
        I've done some research and I've come up with two ways to open native calendar from inside the app using NSURL
        
        "calshow://" which opens calendar at current date
        "calshow:\(someNSDate.timeIntervalSinceReferenceDate)" which opens calendar with date of someNSDate
        I also found this website that lists calshow:x?eventid=id as url but I'm not sure if this works (listed as not public) and I couldn't get it working myself, tried using :
        
        event.calendarItemExternalIdentifier
        event.eventIdentifier
        event.calendarItemIdentifier
*/
        
        //  NSApplication.sharedApplication().openURL(NSURL("calshow:"))
        
        /*
        
        // testView.hidden = true
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 1.0
            self.testView.animator().hidden = !self.testView.hidden
            }, completionHandler: nil)

*/

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