//
//  NodePresenterDelegate.swift
//  Actions
//
//  Created by Chris Beeson on 13/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

protocol NodePresenterDelegate : class  {
    
    func nodePresenterDidChangeTitle(presenter: NodePresenter)
    func nodePresenterDidChangeNotes(presenter: NodePresenter)
    func nodePresenterDidChangeRules(presenter: NodePresenter)
    func nodePresenterDidChangeState(presenter: NodePresenter, toState: NodeState, options:[String]?)

}

extension  NodePresenterDelegate {
    
    func nodePresenterDidChangeTitle(presenter: NodePresenter) {}
    func nodePresenterDidChangeNotes(presenter: NodePresenter) {}
    func nodePresenterDidChangeRules(presenter: NodePresenter) {}
    func nodePresenterDidChangeState(presenter: NodePresenter, toState: NodeState, options:[String]?) {}
    
    // public func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenter) {}
}