//
//  NodePresenterDelegate.swift
//  Filament
//
//  Created by Chris Beeson on 13/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public protocol NodePresenterDelegate : class  {
    
    func nodePresenterDidChangeTitle(presenter: NodePresenter)
    func nodePresenterDidChangeNotes(presenter: NodePresenter)
    func nodePresenterDidChangeRules(presenter: NodePresenter)

}

extension  NodePresenterDelegate {
    
    func nodePresenterDidChangeTitle(presenter: NodePresenter) {}
    func nodePresenterDidChangeNotes(presenter: NodePresenter) {}
    func nodePresenterDidChangeRules(presenter: NodePresenter) {}
    
    // public func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenter) {}
}