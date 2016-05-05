//
//  InfoViewController.swift
//  Actions
//
//  Created by Chris Beeson on 17/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import AppKit
import ActionsKit

class InfoViewController : NSViewController {
    
    @IBOutlet weak var upgradeButton: NSButton!
    @IBOutlet weak var licenceStatusTextfield: NSTextField!
    
    var version: String {
        let dictionary = NSBundle.mainBundle().infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }
    
    @IBAction func upgradeButtonPressed(sender: AnyObject) {
    }
    
    override func viewWillAppear() {
        
        update()
        
        NSNotificationCenter.defaultCenter().addObserverForName("LicenceStateDidChange", object: nil, queue: nil) { (notification) -> Void in
            self.update()
        }
    }
    
    
    func update() {
        
        let licenceState = AppConfiguration.sharedConfiguration.commerceManager.currentLicenceState
        
        licenceStatusTextfield.stringValue = licenceState.humanReadableState()
        
        switch (licenceState ) {
        case .Expired, .Trial : upgradeButton.hidden = false
        default: upgradeButton.hidden = true
        }
        
    }
}
