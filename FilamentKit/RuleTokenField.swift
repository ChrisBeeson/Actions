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
    
    var popover : NSPopover?
    
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
}


/*


public class func setCellClass(factoryId: AnyClass?)
public class func cellClass() -> AnyClass?

public var cell: NSCell?

public func selectedCell() -> NSCell?
public func selectedTag() -> Int

public func setNeedsDisplay() // Use setNeedsDisplay:YES instead.
public func calcSize()

public func updateCell(aCell: NSCell)
public func updateCellInside(aCell: NSCell)
public func drawCellInside(aCell: NSCell)
public func drawCell(aCell: NSCell)
public func selectCell(aCell: NSCell)

*/