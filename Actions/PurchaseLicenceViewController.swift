//
//  PurchaseLicenceViewController.swift
//  Actions
//
//  Created by Chris Beeson on 1/05/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import Cocoa
import Stripe

class PurchaseLicenceViewController : NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var OneYearPriceTextField: NSTextField!
    @IBOutlet weak var oneYearPriceStudentTextField: NSTextField!
    @IBOutlet weak var emailTextField: NSTextField!
    @IBOutlet weak var cardNumberTextField: NSTextField!
    @IBOutlet weak var expiryDateTextField: NSTextField!
    @IBOutlet weak var cvcTextField: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBAction func purchaseButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func radioButtonChanged(sender: AnyObject) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardNumberTextField.delegate = self
    }
    
    
    // TextField Delegate
    
    override func controlTextDidChange(obj: NSNotification) {
        
        if let textField = (obj.object as? NSTextField) {
            textField.stringValue = STPCardValidator.sanitizedNumericStringForString(textField.stringValue)
            let cardNumberState = STPCardValidator.validationStateForNumber(textField.stringValue, validatingCardBrand: true)
            switch cardNumberState {
            case .Valid: textField.textColor = NSColor.greenColor()
            case .Invalid: textField.textColor = NSColor.redColor()
            case .Incomplete: textField.textColor = NSColor.darkGrayColor()
            }
            
        }
    }
}

