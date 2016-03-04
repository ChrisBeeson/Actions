//
//  Configuration.swift
//  Filament
//
//  Created by Chris Beeson on 4/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class Context: NSObject, NSCoding {
    
    var genericRules = [Rule]()
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        static let genericRules = "genericRules"
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        genericRules = aDecoder.decodeObjectForKey(SerializationKeys.genericRules) as! [Rule]
    }
    
    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(genericRules, forKey: SerializationKeys.genericRules)
    }
}
