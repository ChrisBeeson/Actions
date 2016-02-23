//
//  RuleTokenField.swift
//  Filament
//
//  Created by Chris on 23/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class RuleTokenField : NSTokenField, NodePresenterDelegate, NSTokenFieldDelegate {
    
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
    
    
    func refreshTokenField() {
        
        var ruleNames = [String]()
        
        for rulePresenter in nodePresenter!.allRulePresenters() {
            ruleNames.append(rulePresenter.name as String)
        }
        
        self.objectValue = ruleNames
    }
    
    
    public  func textViewDidChangeSelection(notification: NSNotification) {
        
        if let fieldView = self.cell!.fieldEditorForView(self) {
            
            var selectedObjects = [AnyObject]()
            
            for value in fieldView.selectedRanges {
                let range = value.rangeValue
                
                for var i = 0 ; i<range.length; i++ {
                    selectedObjects.append(self.objectValue!.objectAtIndex(range.location + i))
                }
            }
            
            Swift.print("selected objects:\(selectedObjects)")
        }
    }
    
    
    //MARK:Delegate
    
    public func tokenField(tokenField: NSTokenField, displayStringForRepresentedObject representedObject: AnyObject) -> String? {
        
        let rule = representedObject as! Rule
        return rule.name
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