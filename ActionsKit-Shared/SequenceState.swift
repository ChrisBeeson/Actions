//
//  SequenceState.swift
//  Actions
//
//  Created by Chris on 16/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public enum SequenceState : Int {
    
    case noStartDateSet = 1
    case waitingForStart
    case newStartDate
    case running
    case paused
    case hasFailedNode
    case completed
    case void
    
    internal mutating func changeToState(_ newState: SequenceState, presenter:SequencePresenter, options:[String]?) -> SequenceState {
        
        // print("Sequence \(presenter.title):  From \(self)  to \(newState)")
        if self == newState {
            print("Sequence: Self is equal to the new State  \(newState)")
        }
        self = newState
        presenter.delegates.forEach{ $0.sequencePresenterDidChangeState(presenter, toState:newState)}
        presenter.nodes?.forEach{
            let nodePresenter = presenter.nodePresenter($0)
            nodePresenter.currentState.update(nodePresenter)
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshMainTableView"), object: nil)
        return newState
    }
    
    
    mutating func update(_ processEvents: Bool, presenter: SequencePresenter) {
        
        let currentState = calculateSequenceState(presenter, ignoreHasFailedNode: false)
        
        if currentState == .completed {
            toState(.completed, presenter: presenter)
            return
        }
        
        if processEvents == true {
            let calcState = self.processCalanderEvents(presenter)
            self.toState(calcState, presenter: presenter)
        } else {
            toState(currentState, presenter: presenter)
        }
    }
    
    
    mutating func toState(_ state: SequenceState, presenter: SequencePresenter) -> SequenceState {
        //if state == self { return self }
        
        switch state {
        case .noStartDateSet : return toNoStartDateSet(presenter)
        case .newStartDate : return toNewStartDate(presenter)
        case .waitingForStart : return toWaitingForStart(presenter, ignoreHasFailedNodes: false)
        case .running : return toRunning(presenter)
        case .paused : return toPaused(presenter)
        case .completed : return toCompleted(presenter)
        case .hasFailedNode : return toHasFailedNode(presenter)
        case .void : fatalError("Void Sequence State")
        }
    }
    
    
    mutating func toNoStartDateSet(_ presenter: SequencePresenter) -> SequenceState {
        guard self != .noStartDateSet else { return self }
        if presenter.date != nil { return toNewStartDate(presenter) }
        
        presenter.nodePresenters.forEach{ $0.currentState.toInactive($0) }
        return changeToState(.noStartDateSet, presenter: presenter, options: nil)
    }
    
    
    mutating func toNewStartDate(_ presenter: SequencePresenter) -> SequenceState {
        
        presenter.delegates.forEach { $0.sequencePresenterUpdatedDate(presenter) }
        
        if presenter.date == nil {
            presenter.nodePresenters.forEach { $0.currentState.toInactive($0) }
            return changeToState(.noStartDateSet, presenter: presenter, options: nil)
        }
        
        let result = processCalanderEvents(presenter)
        presenter.nodePresenters.forEach{ $0.currentState.update($0) }
        
        return toState(result, presenter: presenter)
    }
    
    
    mutating func toWaitingForStart(_ presenter: SequencePresenter, ignoreHasFailedNodes:Bool) -> SequenceState {
        guard self != .waitingForStart else { return self }
        guard presenter.date != nil else { fatalError("Date is NULL") }
        if (presenter.date! as NSDate).isEarlierThanOrEqual(to: Date()) == true { return toRunning(presenter)}
        
        // add timer to refresh on StartDate
        let secsToStart = (presenter.date! as NSDate).secondsLaterThan(Date())
        Timer.schedule(delay: secsToStart+0.1) { timer in
            presenter.updateState(processEvents: true)
        }
        return changeToState(.waitingForStart, presenter: presenter, options: nil)
    }
    
    
    mutating func toRunning(_ presenter: SequencePresenter) -> SequenceState {
        guard self != .running else { return self }
        if (presenter.date! as NSDate).isLaterThan(Date()) == true { return toWaitingForStart(presenter, ignoreHasFailedNodes: false) }
        if let completeDate = presenter.completionDate {
            if (completeDate as NSDate).isEarlierThan(Date()) == true { return toCompleted(presenter) }
        }
        
        return changeToState(.running, presenter:presenter, options: nil)
    }
    
    mutating func toPaused(_ presenter: SequencePresenter) -> SequenceState {
        guard self != .paused else { return self }
        
        return changeToState(.paused, presenter:presenter, options: nil)
    }
    
    
    mutating func toCompleted(_ presenter: SequencePresenter) -> SequenceState {
        guard self != .completed else { return self }
        
        presenter.nodePresenters.forEach { $0.currentState.toCompleted($0) }
        
        //TODO: Maybe some kinda fancy tick Animation
        
        delay(0.5, closure: {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshMainTableView"), object: nil)
        })
        
        return changeToState(.completed, presenter:presenter, options: nil)
    }
    
    
    mutating func toHasFailedNode(_ presenter: SequencePresenter) -> SequenceState {
        guard self != .hasFailedNode else { return self }
        
        return changeToState(.hasFailedNode, presenter:presenter, options: nil)
    }
    
    
    func processCalanderEvents(_ presenter: SequencePresenter) -> SequenceState {
        guard presenter.date != nil else { return .noStartDateSet }
        
        let result = presenter.sequence.SolveSequence { (node, state, errors) in
            let nodePresenter = presenter.nodePresenter(node)
            nodePresenter.errors = errors
            nodePresenter.currentState.toState(state, presenter:nodePresenter, ignoreError: true)
        }
        return calculateSequenceState(presenter, ignoreHasFailedNode: !result)
    }
    
    
    func calculateSequenceState(_ presenter: SequencePresenter, ignoreHasFailedNode:Bool) -> SequenceState {
        presenter.completionDate = nil
        guard presenter.date != nil else { return .noStartDateSet }
        
        for nodePresenter in presenter.nodePresenters {
            if nodePresenter.currentState == .error { return .hasFailedNode }
            if nodePresenter.currentState == .waitingForUserInput { return .paused }
        }
        
        var state = SequenceState.void
        
            if (presenter.date as NSDate?)?.isLaterThan(Date()) == true { state = .waitingForStart }
            if (presenter.date as NSDate?)?.isEarlierThan(Date()) == true { state = .running }
            if let finishDate = presenter.nodes?.last?.event?.endDate {
                presenter.completionDate = finishDate
                if (finishDate as NSDate).isEarlierThan(Date()) == true { state = .completed }
            }
        
        return state
    }
}
