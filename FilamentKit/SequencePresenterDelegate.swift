//
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2016 Andris Ltd. All rights reserved.
//


public protocol SequencePresenterDelegate : class {

    func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenter)
    func sequencePresenterWillChangeNodeLayout(sequencePresenter: SequencePresenter)
    func sequencePresenterDidUpdateChainContents(insertedNodes:[nodeAtIndex], deletedNodes:[nodeAtIndex])
    func sequencePresenterUpdatedDate(sequencePresenter: SequencePresenter)
    func sequencePresenterUpdatedCalendarEvents(success:Bool, firstFailingNode:Node?)
    func sequencePresenterDidChangeStatus(sequencePresenter: SequencePresenter, toStatus:SequenceStatus)
    
    
    func sequencePresenterDidFinishChangingNodeLayout(sequencePresenter: SequencePresenter)
}


extension  SequencePresenterDelegate {
    
    public func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenter) {}
    public func sequencePresenterWillChangeNodeLayout(sequencePresenter: SequencePresenter) {}
    public func sequencePresenterDidUpdateChainContents(insertedNodes:[nodeAtIndex], deletedNodes:[nodeAtIndex]) {}
    public func sequencePresenterUpdatedDate(sequencePresenter: SequencePresenter) {}
    public func sequencePresenterUpdatedCalendarEvents(success:Bool, firstFailingNode:Node?) {}
    public func sequencePresenterDidChangeStatus(sequencePresenter: SequencePresenter, toStatus:SequenceStatus) {}
    
    
    public func sequencePresenterDidFinishChangingNodeLayout(sequencePresenter: SequencePresenter) {}
}
