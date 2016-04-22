//
//  Actions
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2016 Andris Ltd. All rights reserved.
//

import AppKit

public protocol SequencePresenterDelegate : class {

    func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenter)
    func sequencePresenterDidUpdateChainContents(insertedNodes:Set<NSIndexPath>, deletedNodes:Set<NSIndexPath>)
    func sequencePresenterUpdatedDate(sequencePresenter: SequencePresenter)
    func sequencePresenterDidChangeState(sequencePresenter: SequencePresenter, toState:SequenceState)
    func sequencePresenterDidChangeGeneralRules(sequencePresenter: SequencePresenter)
    
    
    func sequencePresenterDidFinishChangingNodeLayout(sequencePresenter: SequencePresenter)
}


extension  SequencePresenterDelegate {
    
    public func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenter) {}
    public func sequencePresenterDidUpdateChainContents(insertedNodes:Set<NSIndexPath>, deletedNodes:Set<NSIndexPath>) {}
    public func sequencePresenterUpdatedDate(sequencePresenter: SequencePresenter) {}
    //  public func sequencePresenterDidChangeState(sequencePresenter: SequencePresenter, toState:SequenceState) {
    
    //     print("did change state EXTENSION")
  
    //  }
    public func sequencePresenterDidChangeGeneralRules(sequencePresenter: SequencePresenter) {}
    
    
    public func sequencePresenterDidFinishChangingNodeLayout(sequencePresenter: SequencePresenter) {}
}
