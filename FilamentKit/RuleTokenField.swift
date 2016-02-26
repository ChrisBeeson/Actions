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


public class RuleTokenField : NSTokenField, NodePresenterDelegate, NSTokenFieldDelegate {
    
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
        
        switch nodePresenter!.currentStatus {
            case .Inactive, .Ready, .Error : return true
            case .Running, .WaitingForUserInput, .Completed, .Void: return false
        }
    }
    
    public func tokenField(tokenField: NSTokenField, menuForRepresentedObject representedObject: AnyObject) -> NSMenu? {
        /*
        if popover == nil {
            
            popover = NSPopover()
            popover!.animates = true
            popover!.behavior = .Transient
            popover!.appearance = NSAppearance(named: NSAppearanceNameAqua)
            //  popover!.delegate = self
            
        }
        
        let rulePresenter = RulePresenter.rulePresenterForRule(representedObject as! Rule)
        popover!.contentViewController = rulePresenter.detailViewController()
        
        var displayRect = NSMakeRect(NSEvent.mouseLocation().x - 13.5, NSEvent.mouseLocation().y - 16, 5, 5)
        
        displayRect = self.window!.convertRectFromScreen(displayRect)

        self.popover?.showRelativeToRect(displayRect, ofView: self.window!.contentView! , preferredEdge:.MaxY )
*/

        let menu = NSMenu()
        let menuItem = NSMenuItem()
        menuItem.view = detailViewForRule(representedObject as! Rule)
        menu.addItem(menuItem)
        return menu
    }

    
    func detailViewForRule(rule:Rule) -> NSView {
        
        if let presenter = rulePresenters[rule] {
            return presenter.detailViewController().view
        } else {
            let presenter = RulePresenter.rulePresenterForRule(rule)
            rulePresenters[rule] = presenter
            return presenter.detailViewController().view
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

