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
    
    var unarchivedSequence: Sequence {
        // print("calling unarchivedSequence")
        return base!.sequences[0]
    }
    var base : BaseDocument?
    var _sequencePresenter: SequencePresenter?
    
    public var sequencePresenter: SequencePresenter? {
        get {
            if _sequencePresenter == nil {
                _sequencePresenter = SequencePresenter()
                _sequencePresenter!.setSequence(base!.sequences[0])
                _sequencePresenter!.undoManager = self.undoManager
                _sequencePresenter!.representingDocument = self
                return _sequencePresenter
            } else {
                return _sequencePresenter
            }
        }
        set {
            _sequencePresenter = newValue
        }
    }
    
    deinit {
        print("Filament Document deinit")
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
        let url = storageDir().URLByAppendingPathComponent(base!.filename)
        return url
    }
    
    
    public class func newSequenceDocument(title: String) -> FilamentDocument {
        let newDoc = FilamentDocument()
        let actionNodes = [Node(text: "NEW_DOCUMENT_1ST_ACTION".localized, type: .Action, rules: nil), Node(text:  "NEW_DOCUMENT_2ND_ACTION".localized, type: .Action, rules: nil)]
        let sequence = Sequence(name: title, actionNodes: actionNodes)
        sequence.title = !title.isEmpty ? title : "NEW_DOCUMENT_DEFAULT_TITLE".localized
        
        let base = BaseDocument(name:"", sequences:[sequence])
        newDoc.base = base
        //newDoc.unarchivedSequence = sequence
        saveNewDocument(newDoc)
        return newDoc
    }
    
    
    public class func newSequenceDocumentFromArchive(data: NSData) -> FilamentDocument {
        
        let base = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! BaseDocument
        
        let newDoc = FilamentDocument()
        newDoc.base = base
        base.uuid =  NSUUID()
        saveNewDocument(newDoc)
        return newDoc
    }
    
    
    public class func saveNewDocument(document: FilamentDocument) {
        let storageDir = AppConfiguration.sharedConfiguration.storageDirectory
        let url = storageDir().URLByAppendingPathComponent(document.base!.filename)
        
        document.saveToURL(url, ofType: AppConfiguration.filamentFileExtension , forSaveOperation:.SaveOperation, completionHandler: { (Err: NSError?) -> Void in
            if Err != nil {
                print(Err!.localizedDescription)
            }
        })
    }
    
    
    public func save() {
        if self.hasUnautosavedChanges == false { return }
        
        let storageDir = AppConfiguration.sharedConfiguration.storageDirectory
        let url = storageDir().URLByAppendingPathComponent(base!.filename)
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
        
        self.base = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? BaseDocument
        if base != nil {
            sequencePresenter?.setSequence(base!.sequences[0])
        } else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("Could not read file.", comment: "Read error description"),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("File was in an invalid format.", comment: "Read failure reason")
                ])
        }
    }
    
    
    override public func dataOfType(typeName: String) throws -> NSData {
        if base != nil {
            return NSKeyedArchiver.archivedDataWithRootObject(base!)
        }
        
        throw NSError(domain: "ListDocumentDomain", code: -1, userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("Could not archive list", comment: "Archive error description"),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("No presenter was available for the document", comment: "Archive failure reason")
            ])
    }
}
