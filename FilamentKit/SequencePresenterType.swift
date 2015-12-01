/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The definition for the `SequencePresenterType` type. This protocol defines the contract between list presenters and how their lists are presented / archived.
*/



public protocol SequencePresenterType: class {
    
    // MARK: Properties


    weak var delegate: SequencePresenterDelegate? { get set }
    

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
    var archiveableSeq: Sequence { get }
    
    /**
        The presented list items that should be displayed in order. Adopters of the `SequencePresenterType` protocol
        can decide not to show all of the list items within a list.
    */
    var presentedNodes:[Node]? { get }
    
    /// A convenience property that should return the equivalent of `presentedNodes.count`.
    
    var count: Int? { get }
    
    /// A convenience property that should return the equivalent of `presentedNodes.isEmpty`.
    
    var isEmpty: Bool? { get }
}

/**
    We also want to provide implementation to each presenter that conforms
    to this protocol that helps forwards some of its properties to the underlying
    array of presented items. This is provided in this extension of `SequencePresenterType`.
*/
public extension SequencePresenterType {
    
    var isEmpty: Bool? {
        return presentedNodes?.isEmpty
    }
    
    var count: Int? {
        return presentedNodes?.count
    }
}
