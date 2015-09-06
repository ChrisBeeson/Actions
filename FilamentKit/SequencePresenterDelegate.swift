/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The definition for the `SequencePresenterDelegate` type. This protocol defines the contract between the `SequencePresenterType` interactions and receivers of those events (the type that conforms to the `SequencePresenterDelegate` protocol).
*/

/**
    The `SequencePresenterDelegate` type is used to receive events from a `SequencePresenterType` about updates to the
    presenter's layout. This happens, for example, if a `Node` object is inserted into the list or removed
    from the list. For any change that occurs to the list, a delegate message can be called. As a conformer
    you must implement all of these methods, but you may decide not to take any action if the method doesn't
    apply to your use case. For an implementation of `SequencePresenterDelegate`, see the `AllNodesPresenter`
    or `IncompleteNodesPresenter` types.
*/
public protocol SequencePresenterDelegate: class {
    /**
        A `NodePresenterType` invokes this method on its delegate when a large change to the underlying
        list changed, but the presenter couldn't resolve the granular changes. A full layout change includes
        changing anything on the underlying list: list item toggling, text updates, color changes, etc. This
        is invoked, for example, when the list is initially loaded, because there could be many changes that
        happened relative to an empty list--the delegate should just reload everything immediately.  This
        method is not wrapped in `listPresenterWillChangeListLayout(_:isInitialLayout:)` and
        `sequencePresenterDidChangeNodeLayout(_:isInitialLayout:)` method invocations.
    
        - parameter sequencePresenter: The list presenter whose full layout has changed.
    */
    func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenterType)
    
    /**
        A `SequencePresenterType` invokes this method on its delegate before a set of layout changes occur. This
        could involve list item insertions, removals, updates, toggles, etc. This can also include changes to
        the color of the `SequencePresenterType`.  If `isInitialLayout` is `true`, it means that the new list is
        being presented for the first time--for example, if `setList(_:)` is called on the `SequencePresenterType`,
        the delegate will receive a `listPresenterWillChangeListLayout(_:isInitialLayout:)` call where
        `isInitialLayout` is `true`.
    
        - parameter sequencePresenter: The list presenter whose presentation will change.
        - parameter isInitialLayout: Whether or not the presenter is presenting the most recent list for the first time.
    */
    func sequencePresenterWillChangeNodeLayout(sequencePresenter: SequencePresenterType, isInitialLayout: Bool)
    
    /**
        A `SequencePresenterType` invokes this method on its delegate when an item was inserted into the list.
        This method is called only if the invocation is wrapped in a call to
        `listPresenterWillChangeListLayout(_:isInitialLayout:)` and `sequencePresenterDidChangeNodeLayout(_:isInitialLayout:)`.
    
        - parameter sequencePresenter: The list presenter whose presentation has changed.
        - parameter node: The list item that has been inserted.
        - parameter index: The index that `node` was inserted into.
    */
    func sequencePresenter(sequencePresenter: SequencePresenterType, didInsertNode node:Node, atIndex index: Int)
    
    /**
        A `SequencePresenterType` invokes this method on its delegate when an item was removed from the list. This
        method is called only if the invocation is wrapped in a call to
        `listPresenterWillChangeListLayout(_:isInitialLayout:)` and `sequencePresenterDidChangeNodeLayout(_:isInitialLayout:)`.
        
        - parameter sequencePresenter: The list presenter whose presentation has changed.
        - parameter node: The list item that has been removed.
        - parameter index: The index that `node` was removed from.
    */
    func sequencePresenter(sequencePresenter: SequencePresenterType, didRemoveNode node:Node, atIndex index: Int)

    /**
        A `SequencePresenterType` invokes this method on its delegate when an item is updated in place. This could
        happen, for example, if the text of a `Node` instance changes. This method is called only if the
        invocation is wrapped in a call to `listPresenterWillChangeListLayout(_:isInitialLayout:)` and
        `sequencePresenterDidChangeNodeLayout(_:isInitialLayout:)`.
        
        - parameter sequencePresenter: The list presenter whose presentation has changed.
        - parameter node: The list item that has been updated.
        - parameter index: The index that `node` was updated at in place.
    */
    func sequencePresenter(sequencePresenter: SequencePresenterType, didUpdateNode node:Node, atIndex index: Int)

    /**
        A `SequencePresenterType` invokes this method on its delegate when an item moved `fromIndex` to `toIndex`.
        This could happen, for example, if the list presenter toggles a `Node` instance and it needs to be
        moved from one index to another.  This method is called only if the invocation is wrapped in a call to
        `listPresenterWillChangeListLayout(_:isInitialLayout:)` and `sequencePresenterDidChangeNodeLayout(_:isInitialLayout:)`.
        
        - parameter sequencePresenter: The list presenter whose presentation has changed.
        - parameter node: The list item that has been moved.
        - parameter fromIndex: The original index that `node` was located at before the move.
        - parameter toIndex: The index that `node` was moved to.
    */
    func sequencePresenter(sequencePresenter: SequencePresenterType, didMoveNode node:Node, fromIndex: Int, toIndex: Int)

    /**
        A `SequencePresenterType` invokes this method on its delegate when the color of the `SequencePresenterType`
        changes. This method is called only if the invocation is wrapped in a call to
        `listPresenterWillChangeListLayout(_:isInitialLayout:)` and `sequencePresenterDidChangeNodeLayout(_:isInitialLayout:)`.
    
        - parameter sequencePresenter: The list presenter whose presentation has changed.
        - parameter color: The new color of the presented list.
    */
    func sequencePresenter(sequencePresenter: SequencePresenterType, didUpdateSequenceNameWithName name:String)

    /**
        A `SequencePresenterType` invokes this method on its delegate after a set of layout changes occur. See
        `listPresenterWillChangeListLayout(_:isInitialLayout:)` for examples of when this is called.
        
        - parameter sequencePresenter: The list presenter whose presentation has changed.
        - parameter isInitialLayout: Whether or not the presenter is presenting the most recent list for the first time.
    */
    func sequencePresenterDidChangeNodeLayout(sequencePresenter: SequencePresenterType, isInitialLayout: Bool)
}
