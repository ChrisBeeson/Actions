//
//  SolverError.swift
//  Actions
//
//  Created by Chris on 7/04/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

struct SolverError {
    var level:SolverErrorLevel = .warning
    var error:SolverErrorType = .void
    var additionalMessage:String?
    var object:Any?
    var node:Node?
    
    init(errorLevel:SolverErrorLevel, error:SolverErrorType, object:Any?, node:Node?) {
        level = errorLevel
        self.error = error
        self.object = object
    }
    
    var errorDescription:String? {
        switch self.error {
        case .noFreePeriods: return "SOLVER_ERROR_COULD_FIND_NO_FREE_PERIODS".localized
        case .nearlyFits: return nil
        case .clash:
            if object != nil {
                if let string = (object as! AvoidPeriod).errorDescription {
                    return "SOLVER_ERROR_CLASHES_WITH".localized + string
                }
            }
            return nil
        case .followsFailedNode: return "SOLVER_ERROR_FOLLOWS_FAILED_NODE".localized
        case .minRequirementsNotMet: return "Internal Error: Solver Min Requirements Not Met"
        case .requiresUserInput, .followsRequiresUserInput: return "SOLVER_WARN_WAITING_FOR_USER".localized
        default: return nil
        }
    }
}

enum SolverErrorLevel {
    case info
    case warning
    case failed
    case fatal
}

enum SolverErrorType {
    case void
    case noFreePeriods
    case nearlyFits
    case clash
    case followsFailedNode
    case requiresUserInput
    case followsRequiresUserInput
    case minRequirementsNotMet
}
