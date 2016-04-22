//
//  File.swift
//  Actions
//
//  Created by Chris Beeson on 27/10/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import AppKit

extension Array where Element: Equatable {
    
    mutating func removeObject<U: Equatable>(object: U) -> Bool {
        for (idx, objectToCompare) in self.enumerate() {  //in old swift use enumerate(self)
            if let to = objectToCompare as? U {
                if object == to {
                    self.removeAtIndex(idx)
                    return true
                }
            }
        }
        return false
    }
    
    mutating func removeObjects(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
    
}

extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}



extension IntegerType {
    
    func isEven() -> Bool { return self % 2 == 0 ? true : false }
    
}

extension String {
    var localized: String {
        
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle(identifier:"com.andris.ActionsKit")!, value: "", comment: "")
    }
}



//TODO: Redo this copy and paste job.  It looks nasty.
// but better than  po self.superview!.superview!.superview!.superview!.superview!.superview!.superview!.superview!

extension NSView {
    
    func findSuperViewWithClass<T>(superViewClass : T.Type) -> NSView? {
        
        var xsuperView : NSView!  = self.superview!
        var foundSuperView : NSView!
        
        while (xsuperView != nil && foundSuperView == nil) {
            
            if xsuperView.self is T {
                foundSuperView = xsuperView
            } else {
                xsuperView = xsuperView.superview
            }
        }
        return foundSuperView
    }
    
}


class Weak<T: AnyObject> {
    weak var value : T?
    init (value: T) {
        self.value = value
    }
}