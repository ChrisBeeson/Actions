//
//  RulePresenterDelegate.swift
//  Actions
//
//  Created by Chris Beeson on 22/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public protocol RulePresenterDelegate : class {
    func rulePresenterDidChangeContent(_ presenter: RulePresenter)
}


extension  RulePresenterDelegate {
    public func rulePresenterDidChangeContent(_ presenter: RulePresenter) {}
}
