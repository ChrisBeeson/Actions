//
//  ApplicationFeaturesManager.swift
//  Actions
//
//  Created by Chris Beeson on 29/04/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import SwiftyStoreKit

public enum ApplicationFeatures {
    case CreateNewSequence(currentAmountOfSequences:Int)
    case Export
    case Import
    case ShowMainTableViewCells
}

public struct Product {
    public static let oneYearSubscription           =  "com.andris.actions.one_year_subscription"
    public static let oneYearSubscriptionStudent    =  "com.andris.actions.one_year_subscription_student"
    
    /*
    var products:[Product] {
        return [self.oneYearSubscription, self.oneYearSubscriptionStudent]
    }
 */
}


public protocol CommerceManagerDelegate {
    func commerceManagerUpdatedState()
}

public struct CommerceManager {
    
    public var delegate : CommerceManagerDelegate?
    public var currentLicenceState:ApplicationLicenceState
    var purchaseEngine = PurchaseEngine()
    
    public init () {
        //TODO: Load from userdefaults while waiting for network.
        currentLicenceState = .Expired
        
        // Load Store 
    }
    
    public mutating func update() {
        currentLicenceState.update { newState in
            
            // This is all so weird.  What the hell am I doing!
            AppConfiguration.sharedConfiguration.commerceManager.currentLicenceState = newState
            NSNotificationCenter.defaultCenter().postNotificationName("LicenceStateDidChange", object: nil)
        }
    }
    
    public func isFeatureActive(feature:ApplicationFeatures) -> Bool {
        switch currentLicenceState {
        case .Beta: return true
        case .Full: return true
        case .Trial: return true
        case .Expired: return false
        }
    }
    
    public func purchaseItem(product:Product) {
        
    }
}