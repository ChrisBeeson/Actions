/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The definition for the `SequencePresenterType` type. This protocol defines the contract between list presenters and how their lists are presented / archived.
*/

/**
    The `SequencePresenterType` protocol defines the building blocks required for an object to be used as a list
    presenter. List presenters are meant to be used where a `List` object is displayed; in essence, a list
    presenter "fronts" a `List` object. With iOS / OS X apps, iOS / OS X widgets, and WatchKit extensions, we
    can classify these interaction models into list presenters. All of the logic can then be abstracted away
    so that the interaction is testable, reusable, and scalable. By defining the core requirements of a list
    presenter through the `SequencePresenterType`, consumers of `SequencePresenterType` instances can share a common
    interaction interface to a list.

    Types that conform to `SequencePresenterType` have other methods to manipulate a list. For example, a
    presenter can allow for inserting list items into the list and moving a list item from one index.  All of
    these updates require that the `SequencePresenterType` notify its delegate (a `SequencePresenterDelegate`) of
    these changes through the common delegate methods. Each of these methods should be surrounded by
    `listPresenterWillChangeListLayout(_:)` and `sequencePresenterDidChangeNodeLayout(_:)` invocations.  For more
    information about the expectations of how a `SequencePresenterDelegate` interacts with a `SequencePresenterType`,
    see the `SequencePresenterDelegate` protocol comments.

    The underlying implementation of the `SequencePresenterType` may use a `List` object to store certain
    properties as a convenience, but there's no need to do that directly. You query an instance of a
    `SequencePresenterType` for its `archiveableList` representation; that is, a representation of the currently
    presented list that can be archiveable. This may happen, for example, when a document needs to save the
    currently presented list in an archiveable form. Note that list presenters should be used on the main
    queue only.
*/
public protocol SequencePresenterType: class {
    
    // MARK: Properties

    /**
        The delegate that receives callbacks from the `SequencePresenterType` when the presentation of the list
        changes.
    */
    weak var delegate: SequencePresenterDelegate? { get set }
    
    /**
        Resets the presented list to a new list. This can be called, for example, when a new list is
        unarchived and needs to be presented. Calls to this method should wrap the entire sequence of changes
        in a single `listPresenterWillChangeListLayout(_:isInitialLayout:)` and
        `sequencePresenterDidChangeNodeLayout(_:isInitialLayout:)` invocation. In more complicated implementations
        of this method, you can find the intersection or difference between the new list's presented list items
        and the old list's presented list items, and then call into the remove/update/move delegate methods to
        inform the delegate of the re-organization. Delegates receive updates if the text of a `Node`
        instance has changed. Delegates also receive a callback if the new color is different from the old
        list's color.
        
        - parameter list: The new list that the `SequencePresenterType` should present.
    */
    func setSequence(sequence: Sequence)
    
    /**
        The color of the presented list. If the new color is different from the old color, notify the delegate
        through the `sequencePresenter(_:didUpdateListColorWithColor:)` method.
    */
    var name:String { get set }

    /**
        An archiveable presentation of the list that that presenter is presenting. This commonly returns the
        underlying list being manipulated. However, this can be computed based on the current state of the
        presenter (color, list items, etc.). If a presenter has changes that are not yet applied to the list,
        the list returned here should have those changes applied.
    */
    var archiveableSequence: Sequence { get }
    
    /**
        The presented list items that should be displayed in order. Adopters of the `SequencePresenterType` protocol
        can decide not to show all of the list items within a list.
    */
    var presentedNodes:[Node] { get }
    
    /// A convenience property that should return the equivalent of `presentedNodes.count`.
    var count: Int { get }
    
    /// A convenience property that should return the equivalent of `presentedNodes.isEmpty`.
    var isEmpty: Bool { get }
}

/**
    We also want to provide implementation to each presenter that conforms
    to this protocol that helps forwards some of its properties to the underlying
    array of presented items. This is provided in this extension of `SequencePresenterType`.
*/
public extension SequencePresenterType {
    var isEmpty: Bool {
        return presentedNodes.isEmpty
    }
    
    var count: Int {
        return presentedNodes.count
    }
}
