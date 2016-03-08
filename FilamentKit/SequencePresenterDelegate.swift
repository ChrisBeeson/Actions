//
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2016 Andris Ltd. All rights reserved.
//


public protocol SequencePresenterDelegate : class {

    func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenter)
    func sequencePresenterWillChangeNodeLayout(sequencePresenter: SequencePresenter)
    func sequencePresenterDidUpdateChainContents(insertedNodes:Set<NSIndexPath>, deletedNodes:Set<NSIndexPath>)
    func sequencePresenterUpdatedDate(sequencePresenter: SequencePresenter)
    func sequencePresenterDidChangeStatus(sequencePresenter: SequencePresenter, toStatus:SequenceStatus)
    func sequencePresenterDidChangeGeneralRules(sequencePresenter: SequencePresenter)
    
    
    func sequencePresenterDidFinishChangingNodeLayout(sequencePresenter: SequencePresenter)
}


extension  SequencePresenterDelegate {
    
    public func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenter) {}
    public func sequencePresenterWillChangeNodeLayout(sequencePresenter: SequencePresenter) {}
    public func sequencePresenterDidUpdateChainContents(insertedNodes:Set<NSIndexPath>, deletedNodes:Set<NSIndexPath>) {}
    public func sequencePresenterUpdatedDate(sequencePresenter: SequencePresenter) {}
    public func sequencePresenterDidChangeStatus(sequencePresenter: SequencePresenter, toStatus:SequenceStatus) {}
    public func sequencePresenterDidChangeGeneralRules(sequencePresenter: SequencePresenter) {}
    
    
    public func sequencePresenterDidFinishChangingNodeLayout(sequencePresenter: SequencePresenter) {}
}
