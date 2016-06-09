//
//  PurchaseEngine.swift
//  Actions
//
//  Created by Chris Beeson on 29/04/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public enum PurchaseEngineType {
    case InAppPurchase
    case Stripe
    
    init() {
        self = Stripe
    }
}

struct PurchaseEngine {
    
    var state = PurchaseEngineType()
    
}