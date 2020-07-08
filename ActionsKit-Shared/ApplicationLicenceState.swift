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
    
    case full(expiryDate:Date)
    case trial(daysRemaining:Int)
    case beta
    case expired
    
    mutating func update(_ completionBlock:@escaping (_ newState:ApplicationLicenceState)->()) {
        // self = .Beta ; return
        guard let user = PFUser.current()  else {
            self = .expired
            completionBlock(self)
            return
        }
        
        // 1. Do we have a licence?
        
        let query = PFQuery(className: "Licence")
        query.whereKey("User", equalTo: user)
        query.findObjectsInBackground {
            (licences: [PFObject]?, error: NSError?) -> Void in
            if licences != nil {
                for licence in licences! {
                    if let expiryDate = licence["expiryDate"] as? Date {
                        if  (Date() as NSDate).isEarlierThanOrEqual(to: expiryDate) {
                            print("Found Valid Licence: \(licence)")
                            self = .full(expiryDate: expiryDate)
                            completionBlock(newState: self)
                            return
                        }
                    }
                }
            }
            
            
            // 2. Are we in trial period
            
            if let user = PFUser.current() {
                if let date = user.createdAt {
                    let daysFromCreation = (Date() as NSDate).days(from: date)
                    if daysFromCreation < AppConfiguration.sharedConfiguration.trialDuration {
                        self = .trial(daysRemaining: AppConfiguration.sharedConfiguration.trialDuration - daysFromCreation)
                        completionBlock(newState: self)
                        return
                    }
                }
                self = .expired
                completionBlock(newState: self)
            }
        }
    }
    
    public func humanReadableState() -> String {
        switch self {
        case .full(let expiryDate):
            return "LICENCE_STATE_FULL".localized + (expiryDate as NSDate).formattedDate(with: .short)
        case .trial(let daysRemaining):
            return "LICENCE_STATE_TRIAL".localized + " (\(daysRemaining) " + "LICENCE_STATE_SUFFIX".localized + ")"
        case .beta: return "LICENCE_STATE_BETA".localized
        case .expired: return "LICENCE_STATE_EXPIRED".localized
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
