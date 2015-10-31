//
//  AppConfiguration.swift
//  Filament
//
//  Created by Chris on 30/10/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation

public class AppConfiguration: NSObject {
    
    public class var defaultFilamentCalendarName:NSString {
        
        return NSLocalizedString("Filament", comment: "")
    }
    
    public class var filamentFileExtension: String {
        return "fil"
    }
    
    public class var defaultFilamentDraftName: String {
        return NSLocalizedString("Filament", comment: "")
    }
    
    
    
}
