//
//  RuleTokenField.swift
//  Filament
//
//  Created by Chris on 23/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import Async

@objc public protocol RuleTokenFieldDelegate  {
    
    func ruleTokenFieldDidSelectObjects(tokenField:RuleTokenField, rules:[AnyObject]?)
}


public class RuleTokenField : NSTokenField, NodePresenterDelegate, NSTokenFieldDelegate, NSMenuDelegate {
    
    var ruleDetailDelegate : RuleTokenFieldDelegate?
    
    private var rulePresenters = [Rule : RulePresenter]()
    
    // var popover : NSPopover?
    
    var nodePresenter : NodePresenter? {
        didSet {
            loadTokenField()
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.delegate = self
    }
    
    func loadTokenField() {
        
        self.objectValue = nodePresenter!.rules
    }
    
    //MARK:Delegate
    
    public func tokenField(tokenField: NSTokenField, displayStringForRepresentedObject representedObject: AnyObject) -> String? {
        
        let rule = representedObject as! Rule
        return rule.name
    }
    
    
    public func tokenField(tokenField: NSTokenField, hasMenuForRepresentedObject representedObject: AnyObject) -> Bool {
        
        switch nodePresenter!.currentState {
            case .Inactive, .Ready, .Error : return true
            case .Running, .WaitingForUserInput, .Completed, .Void: return false
        }
    }
    
    public func tokenField(tokenField: NSTokenField, menuForRepresentedObject representedObject: AnyObject) -> NSMenu? {
        
        let menu = NSMenu()
        let menuItem = NSMenuItem()
        let detailView = detailControllerForRule(representedObject as! Rule)
        menuItem.view = detailView.view
        menu.addItem(menuItem)
        menu.delegate = detailView
        return menu
    }

    
    func detailControllerForRule(rule:Rule) -> RuleViewController {
        
        if let presenter = rulePresenters[rule] {
            return presenter.detailViewController()
        } else {
            let presenter = RulePresenter.rulePresenterForRule(rule)
            presenter.sequencePresenter = nodePresenter?.sequencePresenter
            rulePresenters[rule] = presenter
            return presenter.detailViewController()
        }
    }
    
    

    public override func mouseUp(theEvent: NSEvent) {
        // super.mouseUp(theEvent)
        
        Swift.print("double click")
        
        if theEvent.clickCount > 1 {
            Swift.print("double click")
        }
        
    }
    
    

    /*
    public func textViewDidChangeSelection(notification: NSNotification) {
        
        //     Swift.print(notification.object)
        //    let obj = notification.object

        if let fieldView = self.cell!.fieldEditorForView(self) {
            
            var selectedObjects = [AnyObject]()
            
            for value in fieldView.selectedRanges {
                let range = value.rangeValue
                
                for var i = 0 ; i<range.length; i++ {
                    selectedObjects.append(self.objectValue!.objectAtIndex(range.location + i))
                }
                
                if selectedObjects.count == 0 { return }
                
                if popover == nil {
                    
                    popover = NSPopover()
                    popover!.animates = true
                    popover!.behavior = .Transient
                    popover!.appearance = NSAppearance(named: NSAppearanceNameAqua)
                    //  popover!.delegate = self
                    
                }
                
                let rulePresenter = RulePresenter.rulePresenterForRule(selectedObjects[0] as! Rule)
                popover!.contentViewController = rulePresenter.detailViewController()
                
                
                //      let frame = fieldView.selectedCell()!.controlView!.frame
                Async.main(after: 0.1) {
                self.popover?.showRelativeToRect(self.selectedCell()!.controlView!.frame, ofView: self, preferredEdge:.MinX )
                }
            }
        }
    }
*/
}

