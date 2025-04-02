//
//  InfoViewController.swift
//  Actions
//
//  Created by Chris Beeson on 17/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import AppKit

class InfoViewController : NSViewController {
    
    @IBOutlet weak var upgradeButton: NSButton!
    @IBOutlet weak var licenceStatusTextfield: NSTextField!
    
    var version: String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }
    
    @IBAction func upgradeButtonPressed(sender: AnyObject) {
    }
    
    override func viewWillAppear() {
        
        update()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "LicenceStateDidChange"), object: nil, queue: nil) { (notification) -> Void in
            self.update()
        }
    }
    
    
    func update() {
        
        let licenceState = AppConfiguration.sharedConfiguration.commerceManager.currentLicenceState
        
        licenceStatusTextfield.stringValue = licenceState.humanReadableState()
        
        switch (licenceState ) {
        case .Expired, .Trial : upgradeButton.isHidden = false
        default: upgradeButton.isHidden = true
        }
        
    }
}
