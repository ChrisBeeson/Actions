//
//  RulePresenter.swift
//  Filament
//
//  Created by Chris Beeson on 22/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class RulePresenter {
    
    private var rule : Rule?
    private var delegates = [RulePresenterDelegate]()
    
    
    
    
    
    
    //MARK: Delegate helpers
    
    public func addDelegate(delegate:RulePresenterDelegate) {
        
        if !delegates.contains({$0 === delegate}) {
            delegates.append(delegate)
        }
    }
    
    public func removeDelegate(delegate:RulePresenterDelegate) {
        
        delegates = delegates.filter { return $0 !== delegate }
        //delegates.removeObject(delegate)
    }
    
    
    
}