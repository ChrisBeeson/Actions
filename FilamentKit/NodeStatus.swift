//
//  NodeStatus.swift
//  Filament
//
//  Created by Chris on 15/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

enum NodeStatus: Int {
    
    case Inactive = 1            // has no calendar Event
    case Ready                   // has calendar Event
    case Running                 // is in the middle of an Event
    case WaitingForUserInput
    case Completed               // has past an event
    case Error
    case Void                    // illegal state that we should never be in
    
    
    internal mutating func changeToStatus(newStatus: NodeStatus, presenter:NodePresenter, options:[String]?) -> NodeStatus {
        presenter.delegates.forEach { $0.nodePresenterDidChangeStatus(presenter, toStatus:newStatus, options:nil) }
        print("Node \(presenter.title):  From \(self)  to \(newStatus)")
        if self == newStatus {
            print("Self is equal to the new status")
        }
        
          self = newStatus
        return newStatus
    }
    
    mutating func toStatus(status: NodeStatus, presenter: NodePresenter) -> NodeStatus {
        if status == self { return self }
        
        switch status {
        case Inactive : return toInactive(presenter)
        case Ready : return toReady(presenter, ignoreErrors: false)
        case Running : return toRunning(presenter)
        case WaitingForUserInput : return toWaitingForUserInput(presenter)
        case Completed : return toCompleted(presenter)
        case Error : return toError(presenter)
        case Void : fatalError("Void Node Status")
        }
    }
    
    mutating func toInactive(presenter: NodePresenter) -> NodeStatus {
        guard self != .Inactive else { return self }
        
        presenter.removeCalandarEvent(false)
        return changeToStatus(Inactive, presenter: presenter, options: nil)
    }
    
    
    mutating func toReady(presenter: NodePresenter, ignoreErrors:Bool) -> NodeStatus {
        guard self != .Ready else { return self }
        
        // Moving to ready may mean we are actually in a different state.
        // The only thing it can't be is .Error
        
        let calculatedState = calculateNodeStatus(presenter, ignoreError:ignoreErrors)
        if calculatedState == self { return self }
        
        switch calculatedState {
            
            // add a timer to refresh when status change is due
            
        case .Ready:
            if let event = presenter.node.event {
                let secsToStart = event.startDate.secondsLaterThan(NSDate())
                NSTimer.schedule(delay: secsToStart+0.1) { timer in
                    presenter.updateNodeStatus()
                }
            }
            
        case .Running:
            if let event = presenter.node.event {
                let secsToComplete = event.endDate.secondsLaterThan(NSDate())
                NSTimer.schedule(delay: secsToComplete+0.1) { timer in
                    presenter.updateNodeStatus()
                }
            }
        default: break
        }
        return changeToStatus(calculatedState, presenter: presenter, options: nil)
    }
    
    
    mutating func toRunning(presenter: NodePresenter) -> NodeStatus {
        guard self != .Running else { return self }
        
        return changeToStatus(.Running, presenter:presenter, options: nil)
    }
    
    
    
    mutating func toCompleted(presenter: NodePresenter) -> NodeStatus {
        guard self != .Completed else { return self }
        presenter.isCompleted = true
        return changeToStatus(.Completed, presenter:presenter, options: nil)
    }
    
    
    
    mutating func toError(presenter: NodePresenter) -> NodeStatus {
        guard self != .Error else { return self }
        presenter.removeCalandarEvent(false)
        return changeToStatus(.Error, presenter:presenter, options: nil)
    }
    
    
    mutating func toWaitingForUserInput(presenter: NodePresenter) -> NodeStatus {
        guard self != .WaitingForUserInput else { return self }
        switch self {
            
        case .Inactive: break
            
        default:
            break
        }
        
        return changeToStatus(.WaitingForUserInput, presenter:presenter, options: nil)
    }
    
    
    mutating func update(presenter: NodePresenter) {
        let calcStatus = calculateNodeStatus(presenter, ignoreError: false)
        toStatus(calcStatus, presenter: presenter)
    }
    
    func calculateNodeStatus(presenter: NodePresenter, ignoreError:Bool) -> NodeStatus {
        
        if presenter.isCompleted == true { return .Completed }
        if ignoreError == false && self == .Error { return .Error }
        guard presenter.event != nil else { return .Inactive }
        
        var newStatus = NodeStatus.Void
        if presenter.event!.startDate.isLaterThan(NSDate())  { newStatus = .Ready }
        if presenter.event!.startDate.isEarlierThanOrEqualTo(NSDate()) && presenter.node.event!.endDate.isLaterThanOrEqualTo(NSDate())  {
            newStatus = .Running
        }
        if presenter.event!.endDate.isEarlierThanOrEqualTo(NSDate()) { newStatus = .Completed }
        // print("\(self) - Calculated node status to be \(newStatus)")
        return newStatus
    }
}