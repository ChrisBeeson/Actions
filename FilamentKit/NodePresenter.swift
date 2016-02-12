//
//  NodePresenter.swift
//  Filament
//
//  Created by Chris Beeson on 13/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import EventKit

public class NodePresenter : NSObject {
    
    public var undoManager: NSUndoManager?
    private var delegates = [NodePresenterDelegate]()
    
    var node: Node {
        didSet {
            
        }
    }
    
    
    init(node:Node, delegate:NodePresenterDelegate) {
        self.node = node
        super.init()
        addDelegate(delegate)
    }
    
    var type: NodeType {
        get {
            return node.type
        }
    }
    
    
    var title: String {
        get {
            return node.title
        }
        set {
            node.title = newValue
            delegates.forEach { $0.nodePresenterDidChangeTitle(self) }
            /*
            undoManager?.prepareWithInvocationTarget(self).renameTitle(title)
            let undoActionName = NSLocalizedString("Rename", comment: "")
            undoManager?.setActionName(undoActionName)
*/
        }
    }
    
    var notes: String {
        get {
            return node.notes
        }
        set {
            node.notes = newValue
            delegates.forEach { $0.nodePresenterDidChangeNotes(self) }
            

        }
    }
    
    var sceduledDate :NSDate? {
        get {
            return nil
        }
    }
    
    var rules:[Rule] {
        get {
            return node.rules
        }
    }
    
    func insertRules(rules:[Rule]) {
        
         node.rules.appendContentsOf(rules)
        
         delegates.forEach { $0.nodePresenterDidChangeRules(self) }
    }
    
    func removeRules(rules:[Rule]) {
        
        delegates.forEach { $0.nodePresenterDidChangeRules(self) }
    }
    
    var calendarEvent: EKEvent? {
        get {
            return node.event
        }
    }

    
    // MARK: Delegate management
    
    public func addDelegate(delegate:NodePresenterDelegate) {
        
        if !delegates.contains({$0 === delegate}) {
            delegates.append(delegate)
        } else {
            Swift.print("Already contains delegate")
        }
    }
    
    public func removeDelegate(delegate:NodePresenterDelegate) {
        
        //delegates = delegates.filter { return $0 !== delegate }
        //delegates.removeObject(delegate)
    }
    
}
