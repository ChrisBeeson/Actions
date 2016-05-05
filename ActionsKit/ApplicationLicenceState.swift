//
//  ApplicationState.swift
//  Actions
//
//  Created by Chris Beeson on 29/04/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import Parse
import DateTools

public enum ApplicationLicenceState {
    
    case Full(expiryDate:NSDate)
    case Trial(daysRemaining:Int)
    case Beta
    case Expired
    
    mutating func update(completionBlock:(newState:ApplicationLicenceState)->()) {
        // self = .Beta ; return
        guard let user = PFUser.currentUser()  else {
            self = .Expired
            completionBlock(newState: self)
            return
        }
        
        // 1. Do we have a licence?
        
        let query = PFQuery(className: "Licence")
        query.whereKey("User", equalTo: user)
        query.findObjectsInBackgroundWithBlock {
            (licences: [PFObject]?, error: NSError?) -> Void in
            if licences != nil {
                for licence in licences! {
                    if let expiryDate = licence["expiryDate"] as? NSDate {
                        if  NSDate().isEarlierThanOrEqualTo(expiryDate) {
                            print("Found Valid Licence: \(licence)")
                            self = .Full(expiryDate: expiryDate)
                            completionBlock(newState: self)
                            return
                        }
                    }
                }
            }
            
            
            // 2. Are we in trial period
            
            if let user = PFUser.currentUser() {
                if let date = user.createdAt {
                    let daysFromCreation = NSDate().daysFrom(date)
                    if daysFromCreation < AppConfiguration.sharedConfiguration.trialDuration {
                        self = .Trial(daysRemaining: AppConfiguration.sharedConfiguration.trialDuration - daysFromCreation)
                        completionBlock(newState: self)
                        return
                    }
                }
                self = .Expired
                completionBlock(newState: self)
            }
        }
    }
    
    public func humanReadableState() -> String {
        switch self {
        case Full(let expiryDate):
            return "LICENCE_STATE_FULL".localized + expiryDate.formattedDateWithStyle(.ShortStyle)
        case Trial(let daysRemaining):
            return "LICENCE_STATE_TRIAL".localized + " (\(daysRemaining) " + "LICENCE_STATE_SUFFIX".localized + ")"
        case Beta: return "LICENCE_STATE_BETA".localized
        case Expired: return "LICENCE_STATE_EXPIRED".localized
        }
    }
}


/*
 let gameScore = PFObject(className:"Widget")
 gameScore["score"] = 1337
 gameScore["playerName"] = "Sean Plott"
 gameScore["cheatMode"] = false
 gameScore.saveInBackgroundWithBlock {
 (success: Bool, error: NSError?) -> Void in
 if (success) {
 // The object has been saved.
 } else {
 print(error?.description)
 // There was a problem, check error.description
 }
 }
 */
