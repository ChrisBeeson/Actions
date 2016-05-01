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
    
    case Full
    case Trial(daysRemaining:Int)
    case Beta
    case Expired
    
    init() {
        self = .Dormant
    }
    
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
                            self = .Full
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
