//
//  AvailableRulesViewController.swift
//  Filament
//
//  Created by Chris on 26/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class AvailableRulesViewController : NSViewController,NSTokenFieldDelegate {
    
    @IBOutlet weak var tokenField: NSTokenField!
    
    var nodePresenter: NodePresenter?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //   tokenField.delegate = self
    }
    
    override public func viewWillLayout() {
        super.viewWillLayout()
        
        if nodePresenter != nil  {
            //       tokenField.objectValue = nodePresenter!.availableRules()
        }
    }
    
    
    //MARK:Delegate
    
    public func tokenField(tokenField: NSTokenField, displayStringForRepresentedObject representedObject: AnyObject) -> String? {
        
        let rule = representedObject as! Rule
        return rule.name
    }
    
}