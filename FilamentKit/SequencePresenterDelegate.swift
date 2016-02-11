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
    
    /*
    func sequencePresenter(sequencePresenter: SequencePresenterType, didRemoveNode node:Node, atIndex index: Int)
    func sequencePresenter(sequencePresenter: SequencePresenterType, didUpdateNode node:Node, atIndex index: Int)
    func sequencePresenter(sequencePresenter: SequencePresenterType, didMoveNode node:Node, fromIndex: Int, toIndex: Int)
    func sequencePresenter(sequencePresenter: SequencePresenterType, didUpdateSequenceNameWithName name:String)
    func sequencePresenterDidChangeNodeLayout(sequencePresenter: SequencePresenterType, isInitialLayout: Bool)
*/
    
    func sequencePresenterDidFinishChangingNodeLayout(sequencePresenter: SequencePresenter)
}


extension  SequencePresenterDelegate {
    
    public func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenter) {}
    public func sequencePresenterWillChangeNodeLayout(sequencePresenter: SequencePresenter) {}
    public func sequencePresenterDidUpdateChainContents(insertedNodes:[nodeAtIndex], deletedNodes:[nodeAtIndex]) {}
    public func sequencePresenterDidFinishChangingNodeLayout(sequencePresenter: SequencePresenter) {}
}
