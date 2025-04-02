//
//  ActionsDocument.swift
//  Actions
//
//  Created by Chris Beeson on 7/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa
import ObjectMapper

open class ActionsDocument: NSDocument {
    
    // MARK: Properties
    
    var unarchivedSequence: Sequence {
        return container!.sequences[0]
    }
    var container : Container?
    weak var _sequencePresenter: SequencePresenter?
    
    open var sequencePresenter: SequencePresenter? {
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
    
    override open class func autosavesInPlace() -> Bool {
        return true
    }
    
    open override class func preservesVersions() -> Bool {
        return false
    }
    
    
    // MARK: NSDocument Overrides
    
    override open func defaultDraftName() -> String {
        return AppConfiguration.defaultDraftName
    }
    
    open func storageURL() -> URL {
        let storageDir = AppConfiguration.sharedConfiguration.storageDirectory
        let url = storageDir().appendingPathComponent(container!.filename)
        return url!
    }
    
    
    open class func newDocument(_ title: String) -> ActionsDocument {
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
    
    open class func newDocumentFromArchive(_ data: Data) -> ActionsDocument {
        let newDoc = ActionsDocument()
        newDoc.container = NSKeyedUnarchiver.unarchiveObject(with: data) as? Container
        newDoc.container!.uuid =  UUID().uuidString
        saveNewDocument(newDoc)
        return newDoc
    }
    
    
    open class func saveNewDocument(_ document: ActionsDocument) {
        let storageDir = AppConfiguration.sharedConfiguration.storageDirectory
        let url = storageDir().appendingPathComponent(document.container!.filename)
        
        document.save(to: url!, ofType: AppConfiguration.applicationFileExtension , for:.saveOperation, completionHandler: { (Err: NSError?) -> Void in
            if Err != nil {
                print(Err!.localizedDescription)
            }
        } as! (Error?) -> Void)
    }
    
    class open func newDocumentFromJSON(_ path:URL) -> Bool {
        let container:Container?
        
        do {
            let json = try String(contentsOf: path, encoding: String.Encoding.utf8)
            container = Mapper<Container>().map(json)
        } catch {
            print(error)
            return false
        }
        
        if container != nil {
            container?.uuid = UUID().uuidString
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
    
    open func save() {
        let storageDir = AppConfiguration.sharedConfiguration.storageDirectory
        let url = storageDir().appendingPathComponent(container!.filename)
        do {
            try self.writeSafely(to: url!, ofType: AppConfiguration.applicationFileExtension, for: .saveOperation)
        } catch {
            do {
                print(error)
            }
        }
    }
    
    
    open override func makeWindowControllers() {
    }
    
    open var suggestedExportFilename : String {
        var filename = sequencePresenter!.title.replacingOccurrences(of: " ", with: "_", options:NSString.CompareOptions.caseInsensitive , range: nil)
        filename.append("."+AppConfiguration.applicationFileExtension)
        return filename
    }
    
    open func exportWithFilename(_ filename:URL) {
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
                try JSON.writeToURL(filename, atomically: true, encoding: String.Encoding.utf8 )
            } catch {
                print(error)
            }
        }
    }
    
    
    // MARK: Serialization / Deserialization
    
    override open func read(from data: Data, ofType typeName: String) throws {
        
        container = NSKeyedUnarchiver.unarchiveObject(with: data) as? Container
        if container != nil {
            sequencePresenter?.setSequence(container!.sequences[0])
        } else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("Could not read file.", comment: "Read error description"),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("File was in an invalid format.", comment: "Read failure reason")
                ])
        }
    }
    
    
    override open func data(ofType typeName: String) throws -> Data {
        if container != nil {
            return NSKeyedArchiver.archivedData(withRootObject: container!)
        }
        
        throw NSError(domain: "ListDocumentDomain", code: -1, userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("Could not archive list", comment: "Archive error description"),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("No presenter was available for the document", comment: "Archive failure reason")
            ])
    }
}
