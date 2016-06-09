//
//  Sequence+PasteBoard.swift
//  Actions
//
//  Created by Chris Beeson on 13/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import AppKit

extension Sequence: NSPasteboardWriting, NSPasteboardReading {

    // Writing
    
    func writableTypesForPasteboard(pasteboard: NSPasteboard) -> [String] {
        return [AppConfiguration.UTI.sequence]
    }
    
    func pasteboardPropertyListForType(type: String) -> AnyObject? {
        guard type == AppConfiguration.UTI.sequence else { return nil }
        
        let sequenceCopy = self.copy()
        return NSKeyedArchiver.archivedDataWithRootObject(sequenceCopy)
    }
    
    // Reading
    
    class func readableTypesForPasteboard (pasteboard: NSPasteboard) -> [String] {
        return [AppConfiguration.UTI.sequence]
    }
    
    static func readingOptionsForType(type: String, pasteboard: NSPasteboard) -> NSPasteboardReadingOptions {
        return NSPasteboardReadingOptions.AsKeyedArchive
    }
}