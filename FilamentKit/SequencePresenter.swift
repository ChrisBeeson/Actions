//
//  Filament
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2016 Andris Ltd. All rights reserved.
//

import Foundation
import DateTools
import Async

/*

SequencePresenter is responsible for : SequenceStatus & NodePresenters associated with this sequence.

*/

public enum SequenceStatus: Int { case NoStartDateSet, WaitingForStart, Running, Paused, HasFailedNode, Completed, Void }

public class SequencePresenter : NSObject {
    
    // MARK: Properties
    
    private var sequence: Sequence?
    private var delegates = [SequencePresenterDelegate]()
    private var nodePresenters = [NodePresenter]()
    private var currentStatus = SequenceStatus.Void
    public var undoManager: NSUndoManager?
    public var representingDocument: FilamentDocument? {
        didSet {
            undoManager = representingDocument?.undoManager
        }
    }
    
    public var title: String {
        get {
            return sequence!.title
        }
        set {
            sequence!.title = newValue
        }
    }
    
    var archiveableSeq: Sequence {
        return sequence!
    }
    
    var nodes:[Node]? {
        return sequence!.nodeChain()
    }
    
    public var date : NSDate? {
        return sequence!.date
    }
    
    public var completionDate : NSDate? {
        
        if nodes == nil { return nil}
        if nodes!.count == 0 { return nodes![nodes!.count-1].event?.endDate }
        if let event = nodes![nodes!.count-1].event {
            return event.endDate
        } else {
            return nil
        }
    }
    
    
    public var status:SequenceStatus {
        return currentStatus
    }
    
    
    // MARK: Methods
    

    func setSequence(sequence: Sequence) {
        
        guard sequence != self.sequence else { return }
        
        self.sequence = sequence
        updateSequenceEvents()
        
        delegates.forEach{ $0.sequencePresenterDidRefreshCompleteLayout(self) }
    }
    
    
    public func renameTitle(newTitle:String) {
        
        undoManager?.prepareWithInvocationTarget(self).renameTitle(title)
        let undoActionName = NSLocalizedString("Rename", comment: "")
        undoManager?.setActionName(undoActionName)
        
        title = newTitle
    }
    
    public func setDate(date:NSDate?, isStartDate:Bool) {
        
        if date != nil && sequence!.date != nil && date!.isEqualToDate(sequence!.date!) && isStartDate == sequence?.startsAtDate { return }
        
        self.undoManager?.prepareWithInvocationTarget(self).setDate(self.date, isStartDate: true)
        let undoActionName = NSLocalizedString("Change Date", comment: "")
        self.undoManager?.setActionName(undoActionName)
        
        self.sequence!.date = date
        self.sequence!.startsAtDate = isStartDate
        self.delegates.forEach { $0.sequencePresenterUpdatedDate(self) }
        
        updateSequenceEvents()
    }
    

    /*
        If node and Int is nil then insertNode will create a new untitled node, and place it at the end of the list.
    */
    
    func insertActionNode(var node: Node?, index: Int?) {
        
        delegates.forEach { $0.sequencePresenterWillChangeNodeLayout(self) }
        
        if node == nil {
            node = Node(text: AppConfiguration.defaultActionNodeName, type: .Action, rules: nil)
        }
        
        let oldNodes = sequence!.nodeChain()
        sequence!.insertActionNode(node!, index: index)
        informDelegatesOfChangesToNodeChain(oldNodes)
        
        undoManager?.prepareWithInvocationTarget(self).deleteNodes([node!])
        let undoActionName = NSLocalizedString("Insert Node", comment: "")
        undoManager?.setActionName(undoActionName)
        
        delegates.forEach { $0.sequencePresenterDidFinishChangingNodeLayout(self) }
        
        updateSequenceEvents()
    }
    
    
    func deleteNodes(nodes: [Node]) {
        
        if nodes.isEmpty { return }
        
        let oldNodes = sequence!.nodeChain()
        
        for node in nodes {
            nodePresenters = nodePresenters.filter {$0.node != node}
            sequence!.removeActionNode(node)
        }
        
        informDelegatesOfChangesToNodeChain(oldNodes)
        /*
        for node in nodes.reverse() {
        undoManager?.prepareWithInvocationTarget(self).insertActionNode(node, index: nil)
        let undoActionName = NSLocalizedString("Delete Node", comment: "")
        undoManager?.setActionName(undoActionName)
        }
        */
        
        updateSequenceEvents()
    }
    
    
    public func prepareForCompleteDeletion() {
        
        if currentStatus != .Completed {
            
            for node in nodes! {
                node.deleteEvent()
            }
        }
    }
    
    func informDelegatesOfChangesToNodeChain(oldNodes:[Node]) {
        
        let diff = oldNodes.diff(sequence!.nodeChain())
        
        if (diff.results.count > 0) {
            
            let insertedNodes = Set(diff.insertions.map { NSIndexPath (forItem: $0.idx , inSection: 0)})
            let deletedNodes = Set(diff.deletions.map {NSIndexPath (forItem: $0.idx , inSection: 0)})
            
            delegates.forEach { $0.sequencePresenterDidUpdateChainContents(insertedNodes, deletedNodes:deletedNodes) }
        }
        updateSequenceStatus()
    }
    
    
    // MARK: Events
    
    /* This is the entry to requesting the sequence to recalculate all events */
    
    func updateSequenceEvents() {
        
        //TODO: Process from starting Node
        
        guard sequence != nil else { return }
       
        if date == nil {
            nodes!.forEach{ $0.deleteEvent() }
            nodePresenters.forEach{ $0.currentStatus = .Inactive }
            currentStatus = .NoStartDateSet
            return
        }
        
        let result = sequence!.UpdateEvents()
        
        nodePresenters.forEach{ $0.currentStatus = .Inactive  }  //first reset all nodes
        currentStatus = .Void
        
        if result.success == true {
            updateSequenceStatus()
            return
        }
        
        // the sequence failed, flag node has an error, and all future nodes.
        
        guard result.firstFailedNode != nil else {
            Swift.print("Was expecting the failed Node, but got nothing")
            return
        }
        
        currentStatus = .HasFailedNode
        
        if let index = nodes?.indexOf(result.firstFailedNode!) where index != -1 {
            
            for index in index...nodes!.count-1 {
                let presenter = presenterForNode(nodes![index])
                nodes![index].deleteEvent()
                presenter.currentStatus = .Error
            }
        }
        updateSequenceStatus()
    }
    
    
    // MARK: Status
    
    internal func calcCurrentStatus() -> SequenceStatus {
        
        guard currentStatus != .HasFailedNode else { return .HasFailedNode }
        
        var status = SequenceStatus.Void
        if date == nil { status = .NoStartDateSet }
        if date?.isLaterThan(NSDate()) == true { status = .WaitingForStart }
        if date?.isEarlierThan(NSDate()) == true { status = .Running }
        if completionDate?.isEarlierThan(NSDate()) == true { status = .Completed }
        assert(status != .Void)
        return status
    }
    
    func updateSequenceStatus() {
        
        let status = calcCurrentStatus()
        
        if currentStatus != status {
            currentStatus = status
            // Swift.print("Sequence Status changed: \(currentStatus)")
            delegates.forEach{ $0.sequencePresenterDidChangeStatus(self, toStatus:currentStatus)}
        }
        
        switch currentStatus {
            
        case .WaitingForStart:
            assert(date != nil)
            let secsToStart = date!.secondsLaterThan(NSDate())
            NSTimer.schedule(delay: secsToStart+0.1) { timer in
                self.updateSequenceStatus()
            }
        default: break
        }
        
        updateAllNodesStatus()
    }
    
    
    func updateAllNodesStatus() {
        
        nodePresenters.forEach{ $0.updateNodeStatus() }
    }
    
    
    func presenterForNode(node:Node) -> NodePresenter {
        
        let presenter = nodePresenters.filter {$0.node === node}
        if presenter.count == 1 { return presenter[0] }
        
        let newPresenter = NodePresenter(node: node)
        newPresenter.undoManager = representingDocument?.undoManager
        newPresenter.sequencePresenter = self
        nodePresenters.append(newPresenter)
        return newPresenter
    }
    
    
//MARK: Delegate helpers
    
    public func addDelegate(delegate:SequencePresenterDelegate) {
        
        if !delegates.contains({$0 === delegate}) {
            delegates.append(delegate)
        }
    }
    
    public func removeDelegate(delegate:SequencePresenterDelegate) {
        
        delegates = delegates.filter { return $0 !== delegate }
        //delegates.removeObject(delegate)
    }
}