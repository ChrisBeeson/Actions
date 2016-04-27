//
//  ActionsDocument.swift
//  Actions
//
//  Created by Chris Beeson on 7/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa
import ObjectMapper

public class ActionsDocument: NSDocument {
    
    // MARK: Properties
    
    var unarchivedSequence: Sequence {
        // print("calling unarchivedSequence")
        return container!.sequences[0]
    }
    var container : Container?
    weak var _sequencePresenter: SequencePresenter?
    
    public var sequencePresenter: SequencePresenter? {
        get {
            if _sequencePresenter == nil {
                _sequencePresenter = SequencePresenter()
                _sequencePresenter!.setSequence(container!.sequences[0])
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
        _sequencePresenter = nil
        // print("Actions Document deinit")
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
        return AppConfiguration.defaultDraftName
    }
    
    public func storageURL() -> NSURL {
        let storageDir = AppConfiguration.sharedConfiguration.storageDirectory
        let url = storageDir().URLByAppendingPathComponent(container!.filename)
        return url
    }
    
    
    public class func newDocument(title: String) -> ActionsDocument {
        let newDoc = ActionsDocument()
        let actionNodes = [Node(text: "NEW_DOCUMENT_1ST_ACTION".localized, type: .Action, rules: nil), Node(text:  "NEW_DOCUMENT_2ND_ACTION".localized, type: .Action, rules: nil)]
        let sequence = Sequence(name: title, actionNodes: actionNodes)
        sequence.title = !title.isEmpty ? title : "NEW_DOCUMENT_DEFAULT_TITLE".localized
        
        let container = Container(name:"", sequences:[sequence])
        newDoc.container = container
        //newDoc.unarchivedSequence = sequence
        saveNewDocument(newDoc)
        return newDoc
    }
    
    //MARK: Load
    
    public class func newDocumentFromArchive(data: NSData) -> ActionsDocument {
        let newDoc = ActionsDocument()
        newDoc.container = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Container
        newDoc.container!.uuid =  NSUUID().UUIDString
        saveNewDocument(newDoc)
        return newDoc
    }
    
    
    public class func saveNewDocument(document: ActionsDocument) {
        let storageDir = AppConfiguration.sharedConfiguration.storageDirectory
        let url = storageDir().URLByAppendingPathComponent(document.container!.filename)
        
        document.saveToURL(url, ofType: AppConfiguration.applicationFileExtension , forSaveOperation:.SaveOperation, completionHandler: { (Err: NSError?) -> Void in
            if Err != nil {
                print(Err!.localizedDescription)
            }
        })
    }
    
    class public func newDocumentFromJSON(path:NSURL) -> Bool {
        let container:Container?
        
        do {
            let json = try String(contentsOfURL: path, encoding: NSUTF8StringEncoding)
            container = Mapper<Container>().map(json)
        } catch {
            print(error)
            return false
        }
        
        if container != nil {
            container?.uuid = NSUUID().UUIDString
            let newDocument = ActionsDocument()
            newDocument.container = container
            saveNewDocument(newDocument)
            return true
            
        } else {
            print("Container is NULL")
            return false
        }
    }
    
    //MARK: Save
    
    public func save() {
        let storageDir = AppConfiguration.sharedConfiguration.storageDirectory
        let url = storageDir().URLByAppendingPathComponent(container!.filename)
        do {
            try self.writeSafelyToURL(url, ofType: AppConfiguration.applicationFileExtension, forSaveOperation: .SaveOperation)
        } catch {
            do {
                print(error)
            }
        }
    }
    
    
    public override func makeWindowControllers() {
    }
    
    public var suggestedExportFilename : String {
        var filename = sequencePresenter!.title.stringByReplacingOccurrencesOfString(" ", withString: "_", options:NSStringCompareOptions.CaseInsensitiveSearch , range: nil)
        filename.appendContentsOf("."+AppConfiguration.applicationFileExtension)
        return filename
    }
    
    public func exportWithFilename(filename:NSURL) {
        /*
         if let JSON = Mapper().toJSONString(container!, prettyPrint: true) {
         do {
         try JSON.writeToURL(filename, atomically: true, encoding: NSUTF8StringEncoding )
         } catch {
         print(error)
         }
         }
         */
        
        let export = container!.copy() as! Container
        export.sequences[0].date = nil
        export.sequences[0].nodeChain().forEach{$0.event = nil}
        
        if let JSON = Mapper().toJSONString(export, prettyPrint: true) {
            do {
                try JSON.writeToURL(filename, atomically: true, encoding: NSUTF8StringEncoding )
            } catch {
                print(error)
            }
        }
    }
    
    
    // MARK: Serialization / Deserialization
    
    override public func readFromData(data: NSData, ofType typeName: String) throws {
        
        container = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Container
        if container != nil {
            sequencePresenter?.setSequence(container!.sequences[0])
        } else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("Could not read file.", comment: "Read error description"),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("File was in an invalid format.", comment: "Read failure reason")
                ])
        }
    }
    
    
    override public func dataOfType(typeName: String) throws -> NSData {
        if container != nil {
            return NSKeyedArchiver.archivedDataWithRootObject(container!)
        }
        
        throw NSError(domain: "ListDocumentDomain", code: -1, userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("Could not archive list", comment: "Archive error description"),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("No presenter was available for the document", comment: "Archive failure reason")
            ])
    }
}
