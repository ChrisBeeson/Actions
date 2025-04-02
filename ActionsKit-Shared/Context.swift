//
//  Configuration.swift
//  Actions
//
//  Created by Chris Beeson on 4/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class Context: NSObject, NSCoding {
    
    var genericRules = [Rule]()
    
    // MARK: NSCoding
    
    fileprivate struct SerializationKeys {
        static let genericRules = "genericRules"
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        genericRules = aDecoder.decodeObject(forKey: SerializationKeys.genericRules) as! [Rule]
    }
    
    func encode(with encoder: NSCoder) {
        encoder.encode(genericRules, forKey: SerializationKeys.genericRules)
    }
}
