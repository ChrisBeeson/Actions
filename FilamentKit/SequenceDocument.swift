//
//  SequenceDocument.swift
//  Filament
//
//  Created by Chris Beeson on 31/10/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation

public class ListDocument: NSDocument {
    
    // MARK: Properties
    
    public var unarchivedSequence: Sequence?
    
    public var sequencePresenter: SequencePresenterType? {
        
        didSet { if let unarchivedSeq = unarchivedSequence { sequencePresenter?.setSequence(unarchivedSeq) } }
    }
    
    
    // MARK: Auto Save and Versions
    
    override public class func autosavesInPlace() -> Bool {
        return true
    }
    

    override public func defaultDraftName() -> String {
        return AppConfiguration.defaultFilamentDraftName
    }

    
    // MARK: Serialization / Deserialization
    
    override public func readFromData(data: NSData, ofType typeName: String) throws {
        
        unarchivedSequence = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Sequence
        
        if let unarchivedSeq = unarchivedSequence  {
            
            sequencePresenter?.setSequence(unarchivedSeq)
            return
        }
        
        throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError, userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("Could not read data.", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("Data was in an invalid format.", comment: "")
            ])
    }
    
    override public func dataOfType(typeName: String) throws -> NSData {
        
        if let archiveableSeq = sequencePresenter?.archiveableSequence {
            
            return NSKeyedArchiver.archivedDataWithRootObject(archiveableSeq)
        }
        
        throw NSError(domain: "ListDocumentDomain", code: -1, userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("Could not archive list", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("No list presenter was available for the document", comment: "")
            ])
    }
    
}
