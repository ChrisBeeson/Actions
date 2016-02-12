//
//  Presenter.swift
//  Filament
//
//  Created by Chris Beeson on 13/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class Presenter: NSObject {
    
    public var undoManager: NSUndoManager?
    
    internal var delegates = [SequencePresenterDelegate]()
    
    // MARK: Delegate management
    
    public func addDelegate(delegate:SequencePresenterDelegate) {
        
        if !delegates.contains({$0 === delegate}) {
            delegates.append(delegate)
        }
    }
    
    public func removeDelegate(delegate:SequencePresenterDelegate) {
        
        //delegates = delegates.filter { return $0 !== delegate }
        //delegates.removeObject(delegate)
    }

}