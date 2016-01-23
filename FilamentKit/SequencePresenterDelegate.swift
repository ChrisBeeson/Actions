/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The definition for the `SequencePresenterDelegate` type. This protocol defines the contract between the `SequencePresenterType` interactions and receivers of those events (the type that conforms to the `SequencePresenterDelegate` protocol).
*/


public protocol SequencePresenterDelegate: class {

    func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenter)
    
   /*
    func sequencePresenterWillChangeNodeLayout(sequencePresenter: SequencePresenterType, isInitialLayout: Bool)
    func sequencePresenter(sequencePresenter: SequencePresenterType, didInsertNode node:Node, atIndex index: Int)
    func sequencePresenter(sequencePresenter: SequencePresenterType, didRemoveNode node:Node, atIndex index: Int)
    func sequencePresenter(sequencePresenter: SequencePresenterType, didUpdateNode node:Node, atIndex index: Int)
    func sequencePresenter(sequencePresenter: SequencePresenterType, didMoveNode node:Node, fromIndex: Int, toIndex: Int)
    func sequencePresenter(sequencePresenter: SequencePresenterType, didUpdateSequenceNameWithName name:String)
    func sequencePresenterDidChangeNodeLayout(sequencePresenter: SequencePresenterType, isInitialLayout: Bool)
*/
}
