//
//  AddFilamentViewController.swift
//  Actions
//
//  Created by Chris Beeson on 12/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa

class AddCellViewController: NSViewController {

    @IBAction func textChanged(textField: NSTextField) {
        
        //fix:  let cleansedString = textField.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if !cleansedString.isEmpty {
            ActionsDocument.newDocument(cleansedString)
        }
        presenting?.dismissViewController(self)
    }
}
