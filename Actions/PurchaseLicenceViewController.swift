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
import Parse
import ActionsKit

class PurchaseLicenceViewController : NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var OneYearPriceTextField: NSTextField!
    @IBOutlet weak var oneYearPriceStudentTextField: NSTextField!
    @IBOutlet weak var emailTextField: NSTextField!
    
    @IBOutlet weak var cardNumberTextField: NSTextField!
    @IBOutlet weak var expiryDateMonthTextField: NSTextField!
    @IBOutlet weak var expiryDateYearTextField: NSTextField!
    @IBOutlet weak var cvcTextField: NSTextField!
    
    @IBOutlet weak var purchaseDetailsStackView: NSStackView!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var purchaseButton: NSButton!
    
    @IBOutlet weak var radioButtonOne: NSButton!
    @IBOutlet weak var radioButtonTwo: NSButton!
    @IBOutlet weak var priceTextFieldOne: NSTextField!
    @IBOutlet weak var priceTextFieldTwo: NSTextField!
    
    var purchasing = false
    var selectedPurchaseItem = 1
    
    var cardParams = STPCardParams() //Stripe Handling
    
    //MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardNumberTextField.delegate = self
        expiryDateMonthTextField.delegate = self
        expiryDateYearTextField.delegate = self
        cvcTextField.delegate = self
        
        #if NONAPPSTORE
            purchaseDetailsStackView.hidden = false
        #else
            purchaseDetailsStackView.hidden = true
        #endif
    }
    
    
    @IBAction func purchaseButtonPressed(sender: AnyObject) {
        #if NONAPPSTORE
            attemptStripePurchase()
        #else
            // attemptIAPPurchase()
        #endif
    }
    
    @IBAction func radioButtonChanged(sender: AnyObject) {
        switch sender.tag {
        case 1: radioButtonOne.state = NSOnState ; radioButtonTwo.state = NSOffState;selectedPurchaseItem = 1
        case 2: radioButtonOne.state = NSOffState ; radioButtonTwo.state = NSOnState; selectedPurchaseItem = 2
        default:break
        }
    }
    
    
    
    //MARK: Stripe Handling
    // TextField Delegate
    
    override func controlTextDidChange(obj: NSNotification) {
        guard let textField = (obj.object as? NSTextField) else { return }
        
        var validState: STPCardValidationState = .Incomplete
        
        switch textField {
        case  cardNumberTextField:
            textField.stringValue = STPCardValidator.sanitizedNumericStringForString(textField.stringValue)
            validState = STPCardValidator.validationStateForNumber(textField.stringValue, validatingCardBrand: true)
            cardParams.number = textField.stringValue
            
        case expiryDateMonthTextField:
            textField.stringValue = STPCardValidator.sanitizedNumericStringForString(textField.stringValue)
            validState = STPCardValidator.validationStateForExpirationMonth(textField.stringValue)
            cardParams.expMonth = UInt(textField.stringValue)!
            
        case expiryDateYearTextField:
            textField.stringValue = STPCardValidator.sanitizedNumericStringForString(textField.stringValue)
            validState = STPCardValidator.validationStateForExpirationYear(textField.stringValue, inMonth:String(cardParams.expMonth))
            cardParams.expYear = UInt(textField.stringValue)!
            
        case cvcTextField:
            let cardBrand = STPCardValidator.brandForNumber(cardNumberTextField.stringValue)
            validState = STPCardValidator.validationStateForCVC(textField.stringValue , cardBrand:cardBrand)
            cardParams.cvc = textField.stringValue
            
        default: break
        }
        
        switch validState {
        case .Valid: textField.textColor = NSColor.greenColor()
        case .Invalid: textField.textColor = NSColor.redColor()
        case .Incomplete: textField.textColor = NSColor.darkGrayColor()
        }
        
        if purchasing != true {
            purchaseButton.enabled = STPCardValidator.validationStateForCard(cardParams) == .Valid ? true : false
        }
    }
    
    
    func attemptStripePurchase() {
        guard purchasing == false else { return }
        guard STPCardValidator.validationStateForCard(cardParams) == .Valid else { return }
        
        togglePurchasing(true)
        
        STPAPIClient.sharedClient().createTokenWithCard(cardParams) { (token, error) -> Void in
            if let error = error  {
                self.togglePurchasing(false)
                self.showErrorModal(error)
            }
            else if let token = token {
                self.purchaseProductWithToken(token)
            }
        }
    }
    
    func purchaseProductWithToken(token:STPToken) {
        guard let userId = PFUser.currentUser()?.objectId else {
            self.togglePurchasing(false)
            print("Current user has no id!")
            return}
        
        let productInfo = ["emailAddress" : emailTextField.stringValue,
                           "cardToken" : token.tokenId,
                           "productCode" : "com.andris.actions.one_year_subscription",
                           "userId" : userId]
        
        PFCloud.callFunctionInBackground("purchaseItem", withParameters: productInfo) { (object, error) in
            
            self.togglePurchasing(false)
            
            if error != nil {
                print(error)
                self.showErrorModal(error!) ; return
            }
            self.purchaseWasSuccessful()
        }
    }
    
    //MARK: UI Responses
    
    func togglePurchasing(purchasing:Bool) {
        self.purchasing = purchasing
        purchaseButton.enabled = !purchasing
        progressIndicator.hidden = !purchasing
        if purchasing == true { progressIndicator.startAnimation(self) } else {progressIndicator.stopAnimation(self) }
    }
    
    
    func showErrorModal(error:NSError) {
        let alert = NSAlert()
        alert.informativeText = error.localizedDescription
        alert.showsHelp = false
        alert.addButtonWithTitle("Ok")
        alert.runModal()
    }
    
    func purchaseWasSuccessful() {
        AppConfiguration.sharedConfiguration.commerceManager.update()
       
        let alert = NSAlert()
        alert.informativeText = "PURCHASE SUCCESSFULL".localized
        alert.showsHelp = false
        alert.addButtonWithTitle("OK".localized)
        alert.runModal()
        self.dismissViewController(self)
    }
}

