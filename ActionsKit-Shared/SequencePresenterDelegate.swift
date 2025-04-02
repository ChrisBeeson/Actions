//
//  Actions
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2016 Andris Ltd. All rights reserved.
//

import Foundation

public protocol SequencePresenterDelegate : class {

    func sequencePresenterDidRefreshCompleteLayout(_ sequencePresenter: SequencePresenter)
    func sequencePresenterDidUpdateChainContents(_ insertedNodes:Set<IndexPath>, deletedNodes:Set<IndexPath>)
    func sequencePresenterUpdatedDate(_ sequencePresenter: SequencePresenter)
    func sequencePresenterDidChangeState(_ sequencePresenter: SequencePresenter, toState:SequenceState)
    func sequencePresenterDidChangeGeneralRules(_ sequencePresenter: SequencePresenter)
    func sequencePresenterDidFinishChangingNodeLayout(_ sequencePresenter: SequencePresenter)
}


extension  SequencePresenterDelegate {
    
    public func sequencePresenterDidRefreshCompleteLayout(_ sequencePresenter: SequencePresenter) {}
    public func sequencePresenterDidUpdateChainContents(_ insertedNodes:Set<IndexPath>, deletedNodes:Set<IndexPath>) {}
    public func sequencePresenterUpdatedDate(_ sequencePresenter: SequencePresenter) {}
    public func sequencePresenterDidChangeGeneralRules(_ sequencePresenter: SequencePresenter) {}
    public func sequencePresenterDidFinishChangingNodeLayout(_ sequencePresenter: SequencePresenter) {}
}
