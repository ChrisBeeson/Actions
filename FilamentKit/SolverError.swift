//
//  SolverError.swift
//  Filament
//
//  Created by Chris on 7/04/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

struct SolverError {
    var level:SolverErrorLevel = .Warning
    var error:String = "NO_KEY_SET"
    var additionalMessage:String?
    var objects:[AnyObject]?
    
    init(errorLevel:SolverErrorLevel, error:String, objects:[AnyObject]?) {
        level = errorLevel
        self.error = error
        self.objects = objects
    }
}

enum SolverErrorLevel {
    case Info
    case Warning
    case Failed
    case Fatal
}