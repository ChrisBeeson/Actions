//
//  SolverError.swift
//  Actions
//
//  Created by Chris on 7/04/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

struct SolverError {
    var level:SolverErrorLevel = .Warning
    var error:SolverErrorType = .Void
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
        case .NoFreePeriods: return "SOLVER_ERROR_COULD_FIND_NO_FREE_PERIODS".localized
        case .NearlyFits: return nil
        case .Clash:
            if object != nil {
                if let string = (object as! AvoidPeriod).errorDescription {
                    return "SOLVER_ERROR_CLASHES_WITH".localized + string
                }
            }
            return nil
        case .FollowsFailedNode: return "SOLVER_ERROR_FOLLOWS_FAILED_NODE".localized
        case .MinRequirementsNotMet: return "Internal Error: Solver Min Requirements Not Met"
        default: return nil
        }
    }
}

enum SolverErrorLevel {
    case Info
    case Warning
    case Failed
    case Fatal
}

enum SolverErrorType {
    case Void
    case NoFreePeriods
    case NearlyFits
    case Clash
    case FollowsFailedNode
    case MinRequirementsNotMet
}