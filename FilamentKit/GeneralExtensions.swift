//
//  File.swift
//  Filament
//
//  Created by Chris Beeson on 27/10/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation


extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

extension IntegerType {
    
    func isEven() -> Bool { return self % 2 == 0 ? true : false }
    
}