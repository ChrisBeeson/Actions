//
//  FilamentDocument.swift
//  Filament
//
//  Created by Chris Beeson on 7/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//


import Cocoa

public class FilamentDocument: NSDocument {

    // MARK: Properties
    
    public var unarchivedSequence: Sequence?
    
    public var sequencePresenter: SequencePresenterType? {
        
        didSet {
                if let unarchivedSequence = unarchivedSequence {
                sequencePresenter?.setSequence(unarchivedSequence)
            }
        }
    }
    
    
    // MARK: Auto Save and Versions
    
    override public class func autosavesInPlace() -> Bool {
        
        return true
    }
    
    // MARK: NSDocument Overrides
    
    /**
    Create window controllers from a storyboard, if desired (based on `makesWindowControllers`).
    The window controller that's used is the initial controller set in the storyboard.
    */
    
    override public func defaultDraftName() -> String {
        
        return AppConfiguration.defaultFilamentDraftName
    }
    
    
    
    // MARK: Serialization / Deserialization
    
    override public func readFromData(data: NSData, ofType typeName: String) throws {
        
        unarchivedSequence = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Sequence
        
        if let unarchivedSeq = unarchivedSequence {
            sequencePresenter?.setSequence(unarchivedSeq)
            return
        }
        
        throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError, userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("Could not read file.", comment: "Read error description"),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("File was in an invalid format.", comment: "Read failure reason")
            ])
    }
    
    
    
    
    override public func dataOfType(typeName: String) throws -> NSData {
        
        if unarchivedSequence != nil {
            return NSKeyedArchiver.archivedDataWithRootObject(unarchivedSequence!)
        }
/*
        if let archiveableSeq = SequencePresenter!. {
            return NSKeyedArchiver.archivedDataWithRootObject(archiveableSeq)
        }
*/

        throw NSError(domain: "ListDocumentDomain", code: -1, userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("Could not archive list", comment: "Archive error description"),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("No list presenter was available for the document", comment: "Archive failure reason")
            ])
    }
}
