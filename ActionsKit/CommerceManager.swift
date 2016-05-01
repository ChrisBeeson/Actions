//
//  ApplicationFeaturesManager.swift
//  Actions
//
//  Created by Chris Beeson on 29/04/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public enum ApplicationFeatures {
    case CreateNewSequence(currentAmountOfSequences:Int)
    case Export
    case Import
    case ShowMainTableViewCells
}

public enum Product : String {
    case OneYearSubscription           =  "com.andris.actions.oneYearSubscription"
    case OneYearSubscriptionStudent    =  "com.andris.actions.oneYearSubscriptionStudent"
}


public protocol CommerceManagerDelegate {
    func commerceManagerUpdatedState()
}

public struct CommerceManager {
    
    public var delegate : CommerceManagerDelegate?
    public var currentLicenceState = ApplicationLicenceState.Dormant
    var purchaseEngine = PurchaseEngine()
    
    mutating func update() {
        currentLicenceState.update { newState in
            self.currentLicenceState = newState
            
            print("New licence State: \(self.currentLicenceState)")
            self.delegate?.commerceManagerUpdatedState()
        }
    }
    
    public func isFeatureActive(feature:ApplicationFeatures) -> Bool {
        switch currentLicenceState {
        case .Beta: return true
        case .Full: return true
        case .Trial: return true
        case .Dormant: return false
        }
    }
    
    public func purchaseItem(product:Product) {
        
    }
}