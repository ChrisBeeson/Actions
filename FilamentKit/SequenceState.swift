//
//  SequenceState.swift
//  Filament
//
//  Created by Chris on 16/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

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
 
        print("Sequence \(presenter.title):  From \(self)  to \(newState)")
        if self == newState { print("Self is equal to the new State") }
       
        self = newState
        
        presenter.delegates.forEach{ $0.sequencePresenterDidChangeState(presenter, toState:newState)}
        presenter.nodePresenters.forEach{ $0.currentState.update($0) }
        
        return newState
    }
    
    
    mutating func update(presenter: SequencePresenter) {
        let calcState = processCalanderEvents(presenter)
        toState(calcState, presenter: presenter)
    }
    
    
    mutating func toState(State: SequenceState, presenter: SequencePresenter) -> SequenceState {
        if State == self { return self }
        
        switch State {
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
        
        presenter.nodePresenters.forEach{ $0.currentState.toInactive($0) }
        
        return changeToState(NoStartDateSet, presenter: presenter, options: nil)
    }
    
    
    mutating func toNewStartDate(presenter: SequencePresenter) -> SequenceState {
        
        presenter.delegates.forEach { $0.sequencePresenterUpdatedDate(presenter) }
        
        if presenter.date == nil {
            presenter.nodePresenters.forEach { $0.removeCalandarEvent(false) }
            presenter.nodePresenters.forEach { $0.currentState.toInactive($0) }
            return changeToState(.NoStartDateSet, presenter: presenter, options: nil)
        }
        
        return toState(processCalanderEvents(presenter), presenter: presenter)
    }
    
    
    
    mutating func toWaitingForStart(presenter: SequencePresenter, ignoreHasFailedNodes:Bool) -> SequenceState {
        guard self != .WaitingForStart else { return self }
        guard presenter.date != nil else { fatalError("Date is NULL") }
    
        
        let secsToStart = presenter.date!.secondsLaterThan(NSDate())
        NSTimer.schedule(delay: secsToStart+0.1) { timer in
            presenter.updateState()
        }
        
        return changeToState(.WaitingForStart, presenter: presenter, options: nil)
    }
    
    
    mutating func toRunning(presenter: SequencePresenter) -> SequenceState {
        guard self != .Running else { return self }
        
        return changeToState(.Running, presenter:presenter, options: nil)
    }
    
    mutating func toPaused(presenter: SequencePresenter) -> SequenceState {
        guard self != .Paused else { return self }
        
        return changeToState(.Paused, presenter:presenter, options: nil)
    }
    
    
    mutating func toCompleted(presenter: SequencePresenter) -> SequenceState {
        guard self != .Completed else { return self }
    
        return changeToState(.Completed, presenter:presenter, options: nil)
    }
    
    
    
    mutating func toHasFailedNode(presenter: SequencePresenter) -> SequenceState {
        guard self != .HasFailedNode else { return self }

        return changeToState(.HasFailedNode, presenter:presenter, options: nil)
    }
    
    
    

    func processCalanderEvents(presenter: SequencePresenter) -> SequenceState {
        
        guard presenter.date != nil else { return .NoStartDateSet }
        
        let result = presenter.sequence.UpdateEvents()
        
        if result.success == true {
            presenter.nodePresenters.forEach{ $0.currentState.toReady($0, ignoreErrors:true) }
            return calculateSequenceState(presenter, ignoreHasFailedNode: true)
        }
        
        // Failed...
        
        guard result.firstFailedNode != nil else {
            Swift.print("Was expecting the failed Node, but got nothing")
            return .Void
        }
        
        if let index = presenter.nodes?.indexOf(result.firstFailedNode!) where index != -1 {
            
            for index in index...presenter.nodes!.count-1 {
                let presenter = presenter.presenterForNode(presenter.nodes![index])
                presenter.currentState.toError(presenter)
            }
        }
        return .HasFailedNode
    }
    
    
    
    func calculateSequenceState(presenter: SequencePresenter, ignoreHasFailedNode:Bool) -> SequenceState {

        guard presenter.date != nil else { return .NoStartDateSet }
        
        for presenter in presenter.nodePresenters {
            if presenter.currentState == .Error {
               return .HasFailedNode
            }
        }
    
        var state = SequenceState.Void
        if presenter.date!.isLaterThan(NSDate()) == true { state = .WaitingForStart }
        if presenter.date!.isEarlierThan(NSDate()) == true { state = .Running }
        
        if let completeDate = presenter.completionDate {
            if completeDate.isEarlierThan(NSDate()) == true { state = .Completed }
        }
        
        return state
    }
}







