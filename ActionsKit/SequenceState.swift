//
//  SequenceState.swift
//  Actions
//
//  Created by Chris on 16/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import Async

public enum SequenceState : Int {
    
    case NoStartDateSet = 1
    case WaitingForStart
    case NewStartDate
    case Running
    case Paused
    case HasFailedNode
    case Completed
    case Void
    
    internal mutating func changeToState(newState: SequenceState, presenter:SequencePresenter, options:[String]?) -> SequenceState {
        
        // print("Sequence \(presenter.title):  From \(self)  to \(newState)")
        if self == newState {
            print("Sequence: Self is equal to the new State  \(newState)")
        }
        self = newState
        presenter.delegates.forEach{ $0.sequencePresenterDidChangeState(presenter, toState:newState)}
        presenter.nodePresenters.forEach{ $0.currentState.update($0) }
        NSNotificationCenter.defaultCenter().postNotificationName("RefreshMainTableView", object: nil)
        return newState
    }
    
    
    mutating func update(processEvents: Bool, presenter: SequencePresenter) {
        
        let currentState = calculateSequenceState(presenter, ignoreHasFailedNode: false)
        
        if currentState == .Completed {
            toState(.Completed, presenter: presenter)
            return
        }
        
        if processEvents == true {
            let calcState = self.processCalanderEvents(presenter)
            self.toState(calcState, presenter: presenter)
        } else {
            toState(currentState, presenter: presenter)
        }
    }
    
    
    mutating func toState(state: SequenceState, presenter: SequencePresenter) -> SequenceState {
        //if state == self { return self }
        
        switch state {
        case NoStartDateSet : return toNoStartDateSet(presenter)
        case NewStartDate : return toNewStartDate(presenter)
        case WaitingForStart : return toWaitingForStart(presenter, ignoreHasFailedNodes: false)
        case Running : return toRunning(presenter)
        case Paused : return toPaused(presenter)
        case Completed : return toCompleted(presenter)
        case HasFailedNode : return toHasFailedNode(presenter)
        case Void : fatalError("Void Sequence State")
        }
    }
    
    
    mutating func toNoStartDateSet(presenter: SequencePresenter) -> SequenceState {
        guard self != .NoStartDateSet else { return self }
        if presenter.date != nil { return toNewStartDate(presenter) }
        
        presenter.nodePresenters.forEach{ $0.currentState.toInactive($0) }
        return changeToState(NoStartDateSet, presenter: presenter, options: nil)
    }
    
    
    mutating func toNewStartDate(presenter: SequencePresenter) -> SequenceState {
        
        presenter.delegates.forEach { $0.sequencePresenterUpdatedDate(presenter) }
        
        if presenter.date == nil {
            presenter.nodePresenters.forEach { $0.currentState.toInactive($0) }
            return changeToState(.NoStartDateSet, presenter: presenter, options: nil)
        }
        
        let result = processCalanderEvents(presenter)
        presenter.nodePresenters.forEach{ $0.currentState.update($0) }
        
        return toState(result, presenter: presenter)
    }
    
    
    mutating func toWaitingForStart(presenter: SequencePresenter, ignoreHasFailedNodes:Bool) -> SequenceState {
        guard self != .WaitingForStart else { return self }
        guard presenter.date != nil else { fatalError("Date is NULL") }
        if presenter.date!.isEarlierThanOrEqualTo(NSDate()) == true { return toRunning(presenter)}
        
        // add timer to refresh on StartDate
        let secsToStart = presenter.date!.secondsLaterThan(NSDate())
        NSTimer.schedule(delay: secsToStart+0.1) { timer in
            presenter.updateState(true)
        }
        return changeToState(.WaitingForStart, presenter: presenter, options: nil)
    }
    
    
    mutating func toRunning(presenter: SequencePresenter) -> SequenceState {
        guard self != .Running else { return self }
        if presenter.date!.isLaterThan(NSDate()) == true { return toWaitingForStart(presenter, ignoreHasFailedNodes: false) }
        if let completeDate = presenter.completionDate {
            if completeDate.isEarlierThan(NSDate()) == true { return toCompleted(presenter) }
        }
        
        return changeToState(.Running, presenter:presenter, options: nil)
    }
    
    mutating func toPaused(presenter: SequencePresenter) -> SequenceState {
        guard self != .Paused else { return self }
        
        return changeToState(.Paused, presenter:presenter, options: nil)
    }
    
    
    mutating func toCompleted(presenter: SequencePresenter) -> SequenceState {
        guard self != .Completed else { return self }
        
        presenter.nodePresenters.forEach { $0.currentState.toCompleted($0) }
        
        //TODO: Maybe some kinda fancy tick Animation
        
        delay(0.5, closure: {
            NSNotificationCenter.defaultCenter().postNotificationName("RefreshMainTableView", object: nil)
        })
        
        return changeToState(.Completed, presenter:presenter, options: nil)
    }
    
    
    mutating func toHasFailedNode(presenter: SequencePresenter) -> SequenceState {
        guard self != .HasFailedNode else { return self }
        
        return changeToState(.HasFailedNode, presenter:presenter, options: nil)
    }
    
    
    func processCalanderEvents(presenter: SequencePresenter) -> SequenceState {
        guard presenter.date != nil else { return .NoStartDateSet }
        
        let result = presenter.sequence.SolveSequence { (node, state, errors) in
            let nodePresenter = presenter.nodePresenter(node)
            nodePresenter.errors = errors
            nodePresenter.currentState.toState(state, presenter:nodePresenter, ignoreError: true)
        }
        return calculateSequenceState(presenter, ignoreHasFailedNode: !result)
    }
    
    
    func calculateSequenceState(presenter: SequencePresenter, ignoreHasFailedNode:Bool) -> SequenceState {
        presenter.completionDate = nil
        guard presenter.date != nil else { return .NoStartDateSet }
        
        for nodePresenter in presenter.nodePresenters {
            if nodePresenter.currentState == .Error { return .HasFailedNode }
            if nodePresenter.currentState == .WaitingForUserInput { return .Paused }
        }
        
        var state = SequenceState.Void
        
            if presenter.date!.isLaterThan(NSDate()) == true { state = .WaitingForStart }
            if presenter.date!.isEarlierThan(NSDate()) == true { state = .Running }
            if let finishDate = presenter.nodes!.last!.event?.endDate {
                presenter.completionDate = finishDate
                if finishDate.isEarlierThan(NSDate()) == true { state = .Completed }
            }
        
        return state
    }
}
