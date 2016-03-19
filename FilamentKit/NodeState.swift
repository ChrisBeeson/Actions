//
//  NodeState.swift
//  Filament
//
//  Created by Chris on 15/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

enum NodeState: Int {
    
    case Inactive = 1            // has no calendar Event
    case Ready                   // has calendar Event
    case Running                 // is in the middle of an Event
    case WaitingForUserInput
    case Completed               // has past an event
    case Error
    case Void                    // illegal state that we should never be in apart from init
    
    
    internal mutating func changeToState(newState: NodeState, presenter:NodePresenter, options:[String]?) -> NodeState {
        
        // print("Node \(presenter.title):  From \(self)  to \(newState)")
        if self == newState { print("Self is equal to the new state") }
        
        self = newState
        presenter.delegates.forEach { $0.nodePresenterDidChangeState(presenter, toState:newState, options:nil) }
        
        return newState
    }
    
    
    mutating func update(presenter: NodePresenter) {
        let calcState = calculateNodeState(presenter, ignoreError: false)
        toState(calcState, presenter: presenter, ignoreError: false)
    }

    
    mutating func toState(state: NodeState, presenter: NodePresenter, ignoreError:Bool) -> NodeState {
        if state == self { return self }
        
        switch state {
        case Inactive : return toInactive(presenter)
        case Ready : return toReady(presenter, ignoreErrors: ignoreError)
        case Running : return toRunning(presenter)
        case WaitingForUserInput : return toWaitingForUserInput(presenter)
        case Completed : return toCompleted(presenter)
        case Error : return toError(presenter)
        case Void : fatalError("Void Node State")
        }
    }
    
    mutating func toInactive(presenter: NodePresenter) -> NodeState {
        guard self != .Inactive else { return self }
        
        presenter.removeCalandarEvent(false)
        return changeToState(Inactive, presenter: presenter, options: nil)
    }
    
    
    mutating func toReady(presenter: NodePresenter, ignoreErrors:Bool) -> NodeState {
        guard self != .Ready else { return self }
        if presenter.isCompleted == true { return toCompleted(presenter) }
        
        // Moving to ready may mean we are actually in a different state.
        let calculatedState = calculateNodeState(presenter, ignoreError:ignoreErrors)
        print("To ready \(self) and calc \(calculatedState)")
        if calculatedState == self { return self }
        
        switch calculatedState {
            
            // add a timer to refresh when state change is due
        case .Ready:
            if let event = presenter.node.event {
                let secsToStart = event.startDate.secondsLaterThan(NSDate())
                NSTimer.schedule(delay: secsToStart+0.1) { timer in
                    presenter.updateNodeState()
                }
            }
            
        case .Running:
            if let event = presenter.node.event {
                let secsToComplete = event.endDate.secondsLaterThan(NSDate())
                NSTimer.schedule(delay: secsToComplete+0.1) { timer in
                    presenter.updateNodeState()
                }
            }
        default: break
        }
        return changeToState(calculatedState, presenter: presenter, options: nil)
    }
    
    
    mutating func toRunning(presenter: NodePresenter) -> NodeState {
        guard self != .Running else { return self }
        
        // presenter.event!.synchronizeCalendarEvent()
        
        return changeToState(.Running, presenter:presenter, options: nil)
    }
    
    
    
    mutating func toCompleted(presenter: NodePresenter) -> NodeState {
        guard self != .Completed else { return self }
        presenter.isCompleted = true
        return changeToState(.Completed, presenter:presenter, options: nil)
    }
    
    
    
    mutating func toError(presenter: NodePresenter) -> NodeState {
        guard self != .Error else { return self }
        guard self != .Completed else { return self }
        presenter.removeCalandarEvent(false)
        return changeToState(.Error, presenter:presenter, options: nil)
    }
    
    
    mutating func toWaitingForUserInput(presenter: NodePresenter) -> NodeState {
        guard self != .WaitingForUserInput else { return self }
        switch self {
            
        case .Inactive: break
            
        default:
            break
        }
        
        return changeToState(.WaitingForUserInput, presenter:presenter, options: nil)
    }
    
        
    func calculateNodeState(presenter: NodePresenter, ignoreError:Bool) -> NodeState {
        
        if presenter.isCompleted == true { return .Completed }
        if ignoreError == false && self == .Error { return .Error }
        guard presenter.event != nil else { return .Inactive }
        
        var newState = NodeState.Void
        if presenter.event!.startDate.isLaterThan(NSDate())  { newState = .Ready }
        if presenter.event!.startDate.isEarlierThanOrEqualTo(NSDate()) && presenter.node.event!.endDate.isLaterThanOrEqualTo(NSDate())  {
            newState = .Running
        }
        if presenter.event!.endDate.isEarlierThanOrEqualTo(NSDate()) { newState = .Completed }
        return newState
    }
}