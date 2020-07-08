//
//  NodePresenterDelegate.swift
//  Actions
//
//  Created by Chris Beeson on 13/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

protocol NodePresenterDelegate : class  {
    
    func nodePresenterDidChangeTitle(_ presenter: NodePresenter)
    func nodePresenterDidChangeNotes(_ presenter: NodePresenter)
    func nodePresenterDidChangeRules(_ presenter: NodePresenter)
    func nodePresenterDidChangeState(_ presenter: NodePresenter, toState: NodeState, options:[String]?)

}

extension  NodePresenterDelegate {
    
    func nodePresenterDidChangeTitle(_ presenter: NodePresenter) {}
    func nodePresenterDidChangeNotes(_ presenter: NodePresenter) {}
    func nodePresenterDidChangeRules(_ presenter: NodePresenter) {}
    func nodePresenterDidChangeState(_ presenter: NodePresenter, toState: NodeState, options:[String]?) {}
    
    // public func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenter) {}
}
