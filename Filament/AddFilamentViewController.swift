//
//  AddFilamentViewController.swift
//  Filament
//
//  Created by Chris Beeson on 12/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa
import FilamentKit

class AddFilamentViewController: NSViewController {

    @IBAction func textChanged(textField: NSTextField) {
        
        let cleansedString = textField.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if !cleansedString.isEmpty {
            FilamentDocument.newSequenceDocument(cleansedString)
        }
        presentingViewController?.dismissViewController(self)
    }
}
