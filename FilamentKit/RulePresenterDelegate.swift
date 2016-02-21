//
//  RulePresenterDelegate.swift
//  Filament
//
//  Created by Chris Beeson on 22/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public protocol RulePresenterDelegate : class {
    
    func rulePresenterDidRefreshCompleteLayout(presenter: RulePresenter)
}


extension  RulePresenterDelegate {
    
    public func rulePresenterDidRefreshCompleteLayout(presenter: RulePresenter) {}
}