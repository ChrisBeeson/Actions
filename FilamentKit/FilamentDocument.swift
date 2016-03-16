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
    
    var unarchivedSequence: Sequence?
    
    private var _sequencePresenter: SequencePresenter?
    
    public var sequencePresenter: SequencePresenter? {
        get {
            if let seq = self.unarchivedSequence {
                if _sequencePresenter == nil {
                    _sequencePresenter = SequencePresenter()
                    _sequencePresenter!.setSequence(seq)
                    _sequencePresenter!.undoManager = self.undoManager
                    _sequencePresenter!.representingDocument = self
                }
                return _sequencePresenter
            } else  {
                fatalError("_sequencePresenter is NULL")
            }
        }
    }
    
    deinit {
        _sequencePresenter = nil
    }
    
    
    // MARK: Auto Save and Versions
    
    override public class func autosavesInPlace() -> Bool {
        return true
    }
    
    public override class func preservesVersions() -> Bool {
        return false
    }
    
    // MARK: NSDocument Overrides
    
    
    override public func defaultDraftName() -> String {
        
        return AppConfiguration.defaultFilamentDraftName
    }
    
    
    
    public func storageURL() -> NSURL {
        let storageDir = AppConfiguration.sharedConfiguration.storageDirectory
        let url = storageDir().URLByAppendingPathComponent(unarchivedSequence!.filename)
        return url
    }
    
    
    public class func newSequenceDocument(title: String) -> FilamentDocument {
        
        let newDoc = FilamentDocument()
        let actionNodes = [Node(text: "NEW_DOCUMENT_1ST_ACTION".localized, type: .Action, rules: nil), Node(text:  "NEW_DOCUMENT_2ND_ACTION".localized, type: .Action, rules: nil)]
        let sequence = Sequence(name: title, actionNodes: actionNodes)
        
        sequence.title = !title.isEmpty ? title : "NEW_DOCUMENT_DEFAULT_TITLE".localized
        newDoc.unarchivedSequence = sequence
        saveNewDocument(newDoc)
        return newDoc
    }
    
    
    public class func newSequenceDocumentFromArchive(data: NSData) -> FilamentDocument {
        
        let sequence = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Sequence
        let newDoc = FilamentDocument()
        newDoc.unarchivedSequence = sequence
        sequence.uuid =  NSUUID()
        saveNewDocument(newDoc)
        return newDoc
    }
    
    
    public class func saveNewDocument(document: FilamentDocument) {
        
        let storageDir = AppConfiguration.sharedConfiguration.storageDirectory
        let url = storageDir().URLByAppendingPathComponent(document.unarchivedSequence!.filename)
        
        document.saveToURL(url, ofType: AppConfiguration.filamentFileExtension , forSaveOperation:.SaveOperation, completionHandler: { (Err: NSError?) -> Void in
            if Err != nil {
                print(Err!.localizedDescription)
            }
        })
    }
    
    
    public func save() {
        
        let storageDir = AppConfiguration.sharedConfiguration.storageDirectory
        let url = storageDir().URLByAppendingPathComponent(_sequencePresenter!.sequence.filename)
        do {
         try self.writeSafelyToURL(url, ofType: AppConfiguration.filamentFileExtension, forSaveOperation: .SaveOperation)
        } catch {
            do {
                print(error)
            }
        }
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
    
        if _sequencePresenter != nil {
            print("Saving")
            return NSKeyedArchiver.archivedDataWithRootObject(_sequencePresenter!.sequence)
        } else if unarchivedSequence != nil {
            print("Saving")
            return NSKeyedArchiver.archivedDataWithRootObject(unarchivedSequence!)
        }
        
        throw NSError(domain: "ListDocumentDomain", code: -1, userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("Could not archive list", comment: "Archive error description"),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("No presenter was available for the document", comment: "Archive failure reason")
            ])
    }
    
}
