//
//  NodeState.swift
//  Actions
//
//  Created by Chris on 15/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

enum NodeState: Int {
    
    case inactive = 1            // has no calendar Event
    case ready                   // has calendar Event
    case running                 // is in the middle of an Event
    case waitingForUserInput
    case inheritedWait
    case completed               // has past an event
    case error
    case inheritedError
    case void                    // illegal state that we should never be in apart from init
    
    internal mutating func changeToState(_ newState: NodeState, presenter:NodePresenter, options:[String]?) -> NodeState {
        
        //print("Node \(presenter.title):  From \(self)  to \(newState)")
        if self == newState { print("Self is equal to the new state") }
        self = newState
        presenter.delegates.forEach { $0.nodePresenterDidChangeState(presenter, toState:newState, options:nil) }
        return newState
    }
    
    mutating func update(_ presenter: NodePresenter) {
        let calcState = calculateNodeState(presenter, ignoreError: false)
        toState(calcState, presenter: presenter, ignoreError: false)
    }


    mutating func toState(_ state: NodeState, presenter: NodePresenter, ignoreError:Bool) -> NodeState {
        if state == self { return self }
        
        switch state {
        case .inactive : return toInactive(presenter)
        case .ready : return toReady(presenter, ignoreErrors: ignoreError)
        case .running : return toRunning(presenter)
        case .waitingForUserInput : return toWaitingForUserInput(presenter)
        case .inheritedWait : return toInheritedWait(presenter)
        case .completed : return toCompleted(presenter)
        case .error : return toError(presenter)
        case .inheritedError : return toInheritedError(presenter)
        case .void : fatalError("Void Node State")
        }
    }
    
    mutating func toInactive(_ presenter: NodePresenter) -> NodeState {
        guard self != .inactive else { return self }
        presenter.removeCalandarEvent(updateState: false)
        return changeToState(.inactive, presenter: presenter, options: nil)
    }
    
    mutating func toReady(_ presenter: NodePresenter, ignoreErrors:Bool) -> NodeState {
        guard self != .ready else { return self }
        if presenter.isCompleted == true { return toCompleted(presenter) }
        
        // Moving to ready may mean we are actually in a different state.
        let calculatedState = calculateNodeState(presenter, ignoreError:ignoreErrors)
        if calculatedState == self { return self }
        
        switch calculatedState {
            
            // add a timer to refresh when state change is due
        case .ready:
            if let event = presenter.node.event {
                let secsToStart = (event.startDate as NSDate).secondsLaterThan(Date())
                Timer.schedule(delay: secsToStart+0.1) { timer in
                    presenter.updateNodeState()
                }
            }
            
        case .running:
            if let event = presenter.node.event {
                let secsToComplete = (event.endDate as NSDate).secondsLaterThan(Date())
                Timer.schedule(delay: secsToComplete+0.1) { timer in
                    presenter.updateNodeState()
                }
            }
        default: break
        }
        return changeToState(calculatedState, presenter: presenter, options: nil)
    }
    
    
    mutating func toRunning(_ presenter: NodePresenter) -> NodeState {
        guard self != .running else { return self }
        // presenter.event!.synchronizeCalendarEvent()
        return changeToState(.running, presenter:presenter, options: nil)
    }
    
    
    mutating func toCompleted(_ presenter: NodePresenter) -> NodeState {
        guard self != .completed else { return self }
        presenter.isCompleted = true
        return changeToState(.completed, presenter:presenter, options: nil)
    }
    
    mutating func toWaitingForUserInput(_ presenter: NodePresenter) -> NodeState {
        guard self != .waitingForUserInput else { return self }
         presenter.removeCalandarEvent(updateState: false)
        return changeToState(.waitingForUserInput, presenter:presenter, options: nil)
    }
    
    mutating func toInheritedWait(_ presenter: NodePresenter) -> NodeState {
        guard self != .inheritedWait else { return self }
         presenter.removeCalandarEvent(updateState: false)
        return changeToState(.inheritedWait, presenter:presenter, options: nil)
    }
    
    mutating func toError(_ presenter: NodePresenter) -> NodeState {
        guard self != .error else { return self }
        guard self != .completed else { return self }
        presenter.removeCalandarEvent(updateState: false)
        return changeToState(.error, presenter:presenter, options: nil)
    }
    
    
    mutating func toInheritedError(_ presenter: NodePresenter) -> NodeState {
        guard self != .error else { return self }
        guard self != .completed else { return self }
        presenter.removeCalandarEvent(updateState: false)
        return changeToState(.inheritedError, presenter:presenter, options: nil)
    }

    func calculateNodeState(_ presenter: NodePresenter, ignoreError:Bool) -> NodeState {
        if presenter.isCompleted == true { return .completed }
        if presenter.sequencePresenter?.currentState == .completed { return .completed }
        
        if ignoreError == false {
         if self == .error  ||
            self == .inheritedError ||
            self == .waitingForUserInput ||
            self == .inheritedWait { return self }
        }

        guard presenter.event != nil else { return .inactive }
        
        var newState = NodeState.void
        if (presenter.event!.startDate as NSDate).isLaterThan(Date())  { newState = .ready }
        if (presenter.event!.startDate as NSDate).isEarlierThanOrEqual(to: Date()) && (presenter.node.event!.endDate as NSDate).isLaterThanOrEqual(to: Date())  {
            newState = .running
        }
        if (presenter.event!.endDate as NSDate).isEarlierThanOrEqual(to: Date()) { newState = .completed }
        return newState
    }
}
